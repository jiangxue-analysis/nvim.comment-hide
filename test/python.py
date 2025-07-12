"""
PST/PFF File Parser Module

This module provides functionality to parse Outlook PST/PFF files,
extract emails, attachments, and metadata.
"""

# Standard library imports
import sys
import os

# Add root directory to Python path for module imports
if __name__ == "__main__":
    import sys, os
    _root_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    sys.path.append(_root_dir)

# Third-party library for PST file parsing
import pypff

# Local utility imports
from modules.app_email.lib.yjSysUtils import *
from modules.app_email.EmailBoxClass import parseReceivedLine, makeEmailHeaderType, parseEmailHeader, get_content_type, decode_body

/* 
    PST File Parser Class
    
    Handles the parsing of PST files and extraction of email content,
    headers, and attachments.
*/
class TPST_Parser:
    def __init__(self, fileName):
        """
        Initialize the PST parser with the target file.
        
        Args:
            fileName (str): Path to the PST file to be parsed
        """
        self.fileName = fileName       # PST file path
        self.messageCount = 0          # Total message counter
        self.__file = None             # Internal file handle
        self.root = None               # Root folder of PST file
        self.EmailBox = None           # Reference to parent EmailBox

    def __del__(self):
        """Destructor to ensure proper file handle cleanup"""
        if self.__file: self.__file.close()
        pass

    def open(self):
        """Open and initialize the PST file for reading"""
        self.__file = pypff.file()
        f = self.__file
        f.open(self.fileName)          # Open the PST file
        self.root = f.get_root_folder()  # Get root folder of PST

    def close(self):
        """Close the PST file handle"""
        self.__file.close()
        self.__file = None

    def traverseFolder(self, messageProc, base=None, _dir=''):
        """
        Recursively traverse PST folder structure and process messages.
        
        Args:
            messageProc: Callback function to process each message
            base: Starting folder (defaults to root)
            _dir: Current directory path for tracking
            
        Returns:
            int: Total number of messages processed
        """
        result = 0
        if not base: base = self.root
        
        # Process all subfolders recursively
        for folder in base.sub_folders:
            if folder.number_of_sub_folders:
                result += self.traverseFolder(messageProc, folder, os.path.join(_dir, folder.name))
            
            # Process messages in current folder
            cnt = len(folder.sub_messages)
            result += cnt
            
            if messageProc and cnt:
                i = 0
                d = '%s/%s' % (_dir, folder.name)
                for message in folder.sub_messages:
                    i += 1
                    if not messageProc(self, i, message, d, cnt): break
        return result

# Global counter for folder numbering
_folder_no = 0

# Constants for PST file properties
value_Null_terminated_String = 0x001E    # Property type for null-terminated strings
value_Unicode_string = 0x001F           # Property type for Unicode strings
entry_Attachment_Filename = 0x3704      # Property ID for attachment filename
entry_Attachement_method = 0x3705       # Property ID for attachment method
entry_Attachment_Filename_long = 0x3707 # Property ID for long attachment filename

def msgProc(self, no, message, _dir, cnt):
    """
    Process individual email message and extract content.
    
    Args:
        self: TPST_Parser instance
        no: Message number in current folder
        message: The email message object
        _dir: Directory path within PST
        cnt: Total messages in current folder
        
    Returns:
        bool: True to continue processing, False to stop
    """
    
    def getBody(message, charset):
        """
        Extract message body content with proper character encoding.
        
        Args:
            message: Email message object
            charset: Character encoding to use
            
        Returns:
            str: Decoded message body
        """
        data = message.get_html_body()
        if data == None:
            data = message.get_plain_text_body()
            if data == None: return ''
        if __debug__: type(data) is bytes
        return decode_body(data, charset)

    global _folder_no
    if no == 1: _folder_no += 1  # Increment folder counter for first message
    if __debug__: assert ExtractFilePath(self.fileName) != ''

    # Initialize message info dictionary
    msg_info = {}
    msg_info['file'] = ExtractFileName(self.fileName)
    msg_info['dir'] = _dir

    # Process email headers
    headers = message.get_transport_headers()
    if headers == None: return True  # Skip if no headers

    headers = parseEmailHeader(headers)
    content_type = get_content_type(headers)
    if len(content_type) >= 2:
        charset = content_type[1]  # Get character encoding from headers
    else:
        charset = 'utf-8'  # Default to UTF-8

    # Build email message object
    clsEmailMessageObject = {}
    msg_info['EmailMessageObject'] = clsEmailMessageObject
    clsEmailMessageObject['Header'] = makeEmailHeaderType(headers)
    clsEmailMessageObject['Body'] = getBody(message, charset)

    # Process attachments if present
    if ('attachments' in dir(message)) and (message.number_of_attachments > 0):

        def attachment_name(attachment):
            """
            Extract attachment filename from record sets.
            
            Args:
                attachment: Attachment object
                
            Returns:
                str: Attachment filename or None if not found
            """
            try:
                if attachment.number_of_record_sets > 0:
                    for entry in attachment.get_record_set(0).entries:
                        if (entry.entry_type == entry_Attachment_Filename_long) and (
                                entry.value_type in [value_Null_terminated_String, value_Unicode_string]):
                            return entry.data_as_string
            except:
                pass
            return None

        attachments = []
        for i in range(message.number_of_attachments):
            attachment = message.get_attachment(i)
            if __debug__: assert type(attachment) is pypff.attachment
            name = attachment_name(attachment)
            if name == None: continue
            
            # Collect attachment info
            file_info = {}
            file_info['name'] = name  # Attachment filename
            file_info['size'] = attachment.get_size()  # Attachment size
            attachments.append(file_info)

            # Save attachment to disk
            try:
                f = open(os.path.join(self.EmailBox.createAttachmentDir(_folder_no, no), name), 'wb')
                f.write(attachment.read_buffer(attachment.get_size()))
                f.close()
            except Exception as e:
                continue  # Skip failed attachments
                #print(e)
                
        if len(attachments) > 0:
            clsEmailMessageObject['Attachments'] = attachments
            #print(attachments)

    # Store processed message info
    # self.EmailBox.makeMessageFile(_folder_no, no, msg_info)  # make json
    self.EmailBox.result.append(msg_info)
    return True

def main(self):
    """
    Main entry point for PST file processing.
    
    Args:
        self: EmailBox instance
        
    Returns:
        list: Processed email messages with metadata
    """
    fileName = self.fileName
    pstParser = TPST_Parser(fileName)
    pstParser.EmailBox = self  # Set parent EmailBox reference
    pstParser.open()           # Open PST file

    # Process all messages in PST
    pstParser.traverseFolder(msgProc)
    pstParser.close()          # Close PST file

    return self.result         # Return processed results

# Module execution handling
if __name__ == "__main__":
    # Print libpff version when run directly
    print('libpff version :', pypff.get_version())
else:
    # Register main function with EmailBox class when imported
    from modules.app_email.EmailBoxClass import EmailBox
    EmailBox.main = main
