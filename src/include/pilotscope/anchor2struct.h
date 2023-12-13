/*-------------------------------------------------------------------------
 *
 * anchor2struct.h
 *	  prototypes for anchor2struct.c.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */
#ifndef __ANCHOR_STRUCT__
#define __ANCHOR_STRUCT__
#include "postgres.h"
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include <stdbool.h>
#include "time.h"

#include "hashtable.h"
#include "cson.h"
#include "cJSON.h"
#include "cson.h"
#include "send_and_receive.h"
#include "hashtable.h"
#include "pilotscope_config.h"
#include "utils.h"

// struct
typedef struct 
{
    char* sql;
    char* physical_plan;
    char*  logical_plan;
    char* execution_time;
    char* tid;
    char** subquery;
    char** card;
    size_t subquery_num;
    size_t card_num;
}PilotTransData;

typedef struct 
{
    int enable;
    char* name;
}SubqueryCardPullAnchor;

typedef struct 
{
    int enable;
    char* name;
    char** subquery;
    double* card;
    size_t  subquery_num;
    size_t  card_num;
}CardPushAnchor;

typedef struct 
{
    int enable;
    char* name;
}ExecutionTimePullAnchor;

typedef struct 
{
    int enable;
    char* name;
}RecordPullAnchor;

// enu
typedef enum 
{
    SUBQUERY_CARD_PULL_ANCHOR,
    CARD_PUSH_ANCHOR,
    EXECUTION_TIME_PULL_ANCHOR,
    RECORD_PULL_ANCHOR,
    PHYSICAL_PLAN_PULL_ANCHOR,
    COST_PUSH_ANCHOR,
    HINT_PUSH_ANCHOR,
    UNKNOWN_ANCHOR
}AnchorName;

// struct
extern PilotTransData* pilot_trans_data;
extern SubqueryCardPullAnchor* subquery_card_pull_anchor;
extern CardPushAnchor* card_push_anchor;
extern ExecutionTimePullAnchor* execution_time_pull_anchor;
extern RecordPullAnchor *record_pull_anchor;
extern AnchorName* ANCHOR_NAME;
extern reflect_item_t Subquery_Card_Fetcher_Anchor_ref_tbl[];
extern reflect_item_t Card_Replace_Anchor_ref_tbl[];
extern reflect_item_t Execution_Time_Fetch_Anchor_ref_tbl[] ;
extern reflect_item_t Record_Fetch_Anchor_ref_tbl[];

// vars
extern int anchor_num;
extern int enableTerminate;
extern int enablePilotscope;
extern int subquery_count;
extern int port;
extern char* host;
extern int enableSend;
extern int enable_parameterized_path_rows_estimation;

// function
extern void init_some_vars();
extern void end_anchor();
extern char* get_card_from_push_anchor(Hashtable* table, const char* key);
extern void store_aimodel_subquery2card();

#endif 