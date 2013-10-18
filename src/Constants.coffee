###
Copyright (c) 2009 - 2013 Markus Kohlhase <mail@markus-kohlhase.de>
###

Properties =
  DEFAULT_PROTOCOL_ID                   : 0x7f
  DEFAULT_LOGIN_RESPONSE_MESSAGE_NR     : 1
  DEFAULT_LOGIN_RESPONSE_MESSAGE_LENGTH : 52
  DEFAULT_LOGIN_REQUEST_MESSAGE_NR      : 1
  DEFAULT_LOGIN_REQUEST_MESSAGE_LENGTH  : 52
  DEFAULT_LOCATION_ID_MIN               : 0
  DEFAULT_LOCATION_ID_MAX               : 65535 # 2^16 - 1 = 65535
  DEFAULT_SPECIFICATION_NR_MIN          : 0
  DEFAULT_SPECIFICATION_NR              : 1
  DEFAULT_LOGIN_FUNCTION_ID             : 1

  # For the logical message number 32 bit are reserved by the 7F protocol,
  # but here for practical reasons it is limited to the positive
  # integer range ( 31 bit ).
  # So the value ranges from 0 to 2^(31) - 1 = 2147483647.
  DEFAULT_LOGICAL_MESSAGE_NR_MIN : 0
  DEFAULT_LOGICAL_MESSAGE_NR_MAX : 2147483647

Command =
  TO         : 0 # int
  FETCH      : 1
  LINK       : 2
  UNLINK     : 3
  TOALWAYS   : 4
  FETCH_ALL  : 5
  LINK_ALL   : 6
  UNLINK_ALL : 7

DataType =
  BYTE          : 0 # int
  WORD          : 1
  LONGWORD      : 2
  STRING        : 3
  BYTEARRAY     : 4
  WORDARRAY     : 5
  LONGWORDARRAY : 6

LoginError =
	INVALID_PROTOCOL_ID           : 0 # bit Nr.
	INVALID_SPECIFICATION_NUMBER  : 1
	INVALID_FUNCION_ID            : 2
	INVALID_LOCATION_ID           : 3

module.exports =
  Properties : Properties
  DataType   : DataType
  Command    : Command
  LoginError : LoginError
