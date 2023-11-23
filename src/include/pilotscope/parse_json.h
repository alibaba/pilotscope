/*-------------------------------------------------------------------------
 *
 * parse_json.h
 *	  prototypes for parse_json.c.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */
#ifndef __PARSE_JSON__
#define __PARSE_JSON__

#include<stdio.h>
#include "postgres.h"
#include "time.h"

#include "cJSON.h"
#include "cson.h"
#include "anchor2struct.h"
#include "send_and_receive.h"
#include "pilotscope_config.h"
#include "utils.h"

extern void parse_json(char* queryString);

#endif 