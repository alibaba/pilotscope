/*-------------------------------------------------------------------------
 *
 * utils.h
 *	  prototypes for utils.c.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */

#ifndef __UTILS__
#define __UTILS__

#include "pilotscope_config.h"
#include <string.h>
#include <postgres.h>
#include "anchor2struct.h"
#include "time.h"
#include "pilotscope_config.h"

// init structs including anchor struct and pilottransdata struct
#define init_struct(anchor,type) anchor = (type*)palloc0(sizeof(type));

// store string for num
// avoid redefinition caused by "#define"
#define store_string_for_num(num,store_var) if(1){\
        char num_string[CHAR_LEN_FOR_NUM]; \
        sprintf(num_string, "%.6f", num);\
        int num_string_length = strlen(num_string);\
        store_var = (char*)palloc((num_string_length+1)*sizeof(char));  \
        strcpy(store_var,num_string);}

// store string
// avoid redefinition caused by "#define"
#define store_string(string_object,store_var) if(1)\
    {\
        int string_length = strlen(string_object);\
        store_var = (char*)palloc((string_length+1)*sizeof(char));  \
        strcpy(store_var,string_object);}

// realloc char**
#define realloc_string_array_object(string_array_object,new_size) string_array_object = (char**)realloc(string_array_object,(new_size)*sizeof(char*));

// back_to_psql
#define back_to_psql(message) ereport(ERROR,(errmsg(message)));


// change flag for anchor
#define change_flag_for_anchor(anchor_flag) anchor_flag = 0;\
         anchor_num--; 

extern void add_anchor_time(char* anchor_name,double anchor_time);
extern clock_t start_to_record_time();
extern double end_time(clock_t starttime);

#endif