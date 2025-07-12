#!/usr/bin/env node

//
// usage
// amp -p '*' ls -1
// or...
// amp git add
//
// bug: what to do when ~/.amp.json is not yet created.
//
const spawn = require('child_process').spawn
const which = require('which').sync
const fs = require('fs')

const DB = process.env.HOME + '/.amp.json'
let db
let l = function () {}
if (process.env.DEBUG) {
  l = function () {
    console.log.apply(console.log, arguments)
  }
}
const isRange = /^(\d+)\-(\d+)$/
const isDigit = /^(\d+)$/

let args = process.argv
// toss out `node scriptname.js`
args = args.slice(2)

let pattern
if (args[0] === '-p' || args[0] === '--pattern') {
  pattern = args[1]
  // toss out `-p mypattern`
  args = args.slice(2)
}

if (!args.length) return printVars()

args = substitute(args)
// console.log('post substitute >', args, '<')

// l('pattern', pattern)
if (pattern) return runWithPattern(pattern, args)

// show what we are executing
// (when no executable command is given, this just prints what was expanded)
console.log(args.join(' '))

// if args[0] does not exist, or is not executable, do nothing.
let cmd
try {
  cmd = which(args[0])
} catch (e) {
  l(e.stack)
  return
}

// run the executable with the expanded args
l(cmd, args.slice(1))
return spawn(cmd, args.slice(1) || [], { stdio: 'inherit' }).on(
  'close',
  (code, signal) => {
    process.exit(code)
  }
)

function substitute(args) {
  // if there is saved data from the last run, try to substitute digits/ranges
  if (!loadDb()) return args
  l('substitute.map')
  let newargs = []
  args.forEach((arg) => {
    l('substitute.map', arg)
    l('substitute.isRange', isRange.test(arg))
    l('substitute.isDigit', isDigit.test(arg))
    if (isRange.test(arg)) newargs = newargs.concat(insertRange(arg))
    else if (isDigit.test(arg)) newargs.push(insertDigit(arg))
    else newargs.push(arg)
  })
  return newargs
}

function insertRange(arg) {
  const args = []

  l('insertRange.arg', arg)
  arg.replace(isRange, (match, start, end, string) => {
    start = parseInt(start, 10)
    end = parseInt(end, 10)
    for (let i = start; i <= end; i++) {
      const val = db[i]
      l('insertRange.val', val)
      if (val) args.push(val)
    }
  })
  l('insertRange args', args)
  if (args.length) return args
  return arg
}

function insertDigit(arg) {
  l('digit')
  return arg.replace(isDigit, (match, digit, string) => {
    l('digit', match, typeof digit)
    const val = db[digit]
    l('val', val)

    if (val) return val
    return string
  })
}

function runWithPattern(pattern, args) {
  l('runWithPattern')
  if ('git' === args[0]) {
    args = [args[0], '-c', 'color.' + args[1] + '=always'].concat(args.slice(1))
  }
  let i = 1
  const re = new RegExp(pattern)

  console.log(args.join(' '))
  const child = spawn(args[0], args.slice(1))
  child.stdout.on('data', (data) => {
    const out = data
      .toString() // its a buffer
      .split('\n') // there are many lines
    out.pop() // get rid of the trailing newline

    const pad = out.length >= 10 ? ' ' : ''

    out.forEach((line) => {
      l('line', line)
      // match after stripping ANSI colors. via http://superuser.com/a/380778
      const m = re.exec(line.replace(/\x1b\[[0-9]*m/g, ''))
      if (m) {
        // if no capture group, just use whole string
        l('match', m)
        db[i] = m[1] || m[0]
      }
      const num = i <= 9 ? i + pad : i
      console.log(num + ' ' + line)
      i++
    })
    l(db)
  })
  child.stderr.on('data', (data) => {
    process.stderr.write(data)
  })
  let saved = false
  child.on('close', saveDB)
  // Also call saveDB() when the parent closes, in case of `| head`.
  // Prevent errors caused by trying to process.stdout.write or console.log
  // after stdout has been closed (e.g. when piping to head, `| head`)
  // https://github.com/mhart/epipebomb/issues/10
  require('epipebomb')(process.stdout, saveDB)
  function saveDB(code) {
    if (saved) return
    saved = true
    fs.writeFile(DB, JSON.stringify(db, null, 2), 'utf8', (err) => {
      if (err) console.log('Problem saving variables ' + err.stack)
      process.exit(code)
    })
  }
}

function loadDb() {
  try {
    db = require(DB)
  } catch (e) {
    l(e)
    return false
  }
  return true
}

function printVars() {
  if (!loadDb()) {
    return console.log('No variables currently saved')
  }
  Object.keys(db).forEach((k, _, keys) => {
    const lhs = keys.length >= 10 ? pad(k, 2) : k
    console.log(lhs, '=', db[k])
  })
}

function pad(s, num) {
  while (s.length < num) s += ' '
  return s
}
