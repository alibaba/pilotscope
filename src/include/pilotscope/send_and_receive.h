/*-------------------------------------------------------------------------
 *
 * send_and_receive.h
 *	  prototypes for send_and_receive.c.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */
#ifndef __SEND_AND_RECEIVE__
#define __SEND_AND_RECEIVE__

#include <stdbool.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "postgres.h"

#include "http.h"
#include "anchor2struct.h"
#include "pilotscope_config.h"

extern int send_and_receive(char* string_of_pilottransdata);
#endif 