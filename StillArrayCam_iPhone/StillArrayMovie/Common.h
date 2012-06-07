//
//  Common.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#ifndef StillArrayMovie_Common_h
#define StillArrayMovie_Common_h

#define USERDEFKEY_SEATNUMBER           @"USERDEFKEY_SEATNUMBER"
#define USERDEFKEY_FTPADDRESS           @"USERDEFKEY_FTPADDRESS"
#define USERDEFKEY_FTPPORT              @"USERDEFKEY_FTPPORT"
#define USERDEFKEY_FTPUSER              @"USERDEFKEY_FTPUSER"
#define USERDEFKEY_FTPPASSWORD          @"USERDEFKEY_FTPPASSWORD"

#define USERDEFKEY_CONTROLADDRESS       @"USERDEFKEY_CONTROLADDRESS"
#define USERDEFKEY_CONTROLPORT          @"USERDEFKEY_CONTROLPORT"

#define READTIMEOUT                     300.0
#define WRITETIMEOUT                    300.0

#define MESSAGE_LENGTH                  18
#define MSGTYPE_READY                   @"R"
#define MSGTYPE_END                     @"E"
#define MSGTYPE_UPLOAD                  @"U"
#define MSGTYPE_START                   @"S"

enum MsgTypeEnum {
    Msg_Ready = 0,
    Msg_EndCapture,
    Msg_UploadDone,
    Msg_StartCapture,
};

#endif
