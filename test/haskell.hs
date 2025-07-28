{-# LANGUAGE OverloadedStrings #-}

module Language.Moonbit.Mbti.Parser where

import Data.Functor
import Data.Maybe
import Language.Moonbit.Lexer
import Language.Moonbit.Mbti.Syntax
import Text.Parsec.Text.Lazy (Parser)

import Text.Parsec

attrCtors :: [(String, Maybe String -> FnAttr)]
attrCtors =
  [ ("deprecated", Deprecated)
  ]

pAttr :: Parser FnAttr
pAttr = do
  _ <- char '#' <?> "‘#’"
  name <- choice (map ((try . string) . fst) attrCtors) <?> "attribute name"
  arg <- optionMaybe $ parens stringLit -- optional argument for the attribute
  case lookup name attrCtors of
    Just ctor -> return $ ctor arg
    Nothing -> parserFail $ "unknown attribute: " ++ name

-- >>> parse pTypeDecl "" "type Node[K, V]"
-- Right (TypeDecl (TName Nothing (TCon "Node" [TName Nothing (TCon "K" []),TName Nothing (TCon "V" [])])))
-- >>> parse pTypeDecl "" "type Node"
-- Right (TypeDecl (TName Nothing (TCon "Node" [])))

pTypeDecl :: Parser Decl
pTypeDecl = do
  _ <- reserved RWType
  name <- identifier
  tyargs <- option [] (brackets (commaSep identifier))
  return $ TypeDecl (TName Nothing (TCon name $ (\n -> TName Nothing $ TCon n []) <$> tyargs))

pTFun :: Parser Type
pTFun = do
  isAsync <- fromMaybe False <$> optionMaybe (reserved RWAsync $> True)
  args <- parens (commaSep pType)
  reservedOp OpArrow
  retTy <- pType
  effEx <- fromMaybe NoAraise <$> optionMaybe pEffectException
  let effects = [EffAsync | isAsync] ++ [EffException effEx]
  return (TFun args retTy effects)

pEffectException :: Parser EffectException
pEffectException =
  try (reserved RWRaisePoly $> AraisePoly)
    <|> try (reserved RWNoRaise $> NoAraise)
    <|> do
      reserved RWRaise
      Araise <$> pType
    <?> "exception effect (raise?, noaraise or raise T)"

pTTuple :: Parser Type
pTTuple = TTuple <$> parens (commaSep pType)

pTPath :: Parser TPath
pTPath = do
  _ <- symbol "@"
  segs <- identifier `sepBy1` slash
  return $ TPath (init segs) (last segs) -- SAFETY: sepBy1 ensures at least one segment

pTCon :: Parser TCon
pTCon = do
  name <- identifier
  tyargs <- option [] (brackets (commaSep pType))
  return $ TCon name tyargs

-- TCon without the ?
pTAtom :: Parser Type
pTAtom = do
  mpath <- optionMaybe (pTPath <* reservedOp OpDot)
  TName mpath <$> pTCon

pTNonFun :: Parser Type
pTNonFun = do
  base <- try pTTuple <|> pTAtom
  isOpt <- option False (symbol "?" $> True)
  if isOpt
    then return $ TName Nothing (TCon "Option" [base])
    else return base

-- >>> parse pTFun "" "async (K, V) -> V raise E"
-- Right (TFun [TName Nothing (TCon "K" []),TName Nothing (TCon "V" [])] (TName Nothing (TCon "V" [])) [EffAsync,EffException (Araise (TName Nothing (TCon "E" [])))])

-- >>> parse pTFun "" "(Int, Bool) -> String?"
-- Right (TFun [TName Nothing (TCon "Int" []),TName Nothing (TCon "Bool" [])] (TName Nothing (TCon "Option" [TName Nothing (TCon "String" [])])) [EffException NoAraise])

-- >>> parse pTFun "" "async (T) -> U noaraise"
-- Right (TFun [TName Nothing (TCon "T" [])] (TName Nothing (TCon "U" [])) [EffAsync,EffException NoAraise])

-- >>> parse pType "" "(A?,B) -> C raise?"
-- Right (TFun [TName Nothing (TCon "Option" [TName Nothing (TCon "A" [])]),TName Nothing (TCon "B" [])] (TName Nothing (TCon "C" [])) [EffException AraisePoly])

pType :: Parser Type
pType =
  choice
    [ try pTFun
    , pTNonFun
    ]

-- pFnSig :: Parser FnSig
-- pFnSig = do

-- pType :: Parser Type
-- pType = do

-- >>> parse pPackageDecl "" "package \"user/repo/path/to/module\""
-- Right (ModulePath {mpUserName = "user", mpModuleName = "repo", mpPackagePath = ["path","to","module"]})

pPackageDecl :: Parser ModulePath
pPackageDecl = reserved RWPackage *> pQuotedModulePath

-- >>> parse pImportDecl "" "import (\"user1/repo1/path/to/module\" \"user2/repo2/another/path\")"
-- Right [ModulePath {mpUserName = "user1", mpModuleName = "repo1", mpPackagePath = ["path","to","module"]},ModulePath {mpUserName = "user2", mpModuleName = "repo2", mpPackagePath = ["another","path"]}]

pImportDecl :: Parser [ModulePath]
pImportDecl = reserved RWImport *> parens (spaces *> pQuotedModulePath `sepBy` spaces <* spaces)

-- >>> parse pModulePath "" "user/modname/path/to/module"
-- Right (ModulePath {mpUserName = "user", mpModuleName = "modname", mpPackagePath = ["path","to","module"]})

pModulePath :: Parser ModulePath
pModulePath = do
  segments <- identifier `sepBy1` slash
  case segments of
    user : modName : pName1 : rest -> return $ ModulePath user modName (pName1 : rest) -- make sure to have at least 1 segment after the module name
    _ -> parserFail "module path must be in the form ‘user/modname/path"

pQuotedModulePath :: Parser ModulePath
pQuotedModulePath = between (char '"') (char '"') pModulePath
