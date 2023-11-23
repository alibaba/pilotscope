
/*-------------------------------------------------------------------------
 *
 * utils.h
 *	   Routines to provide tools for pilotscope.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */

#include "pilotscope/utils.h"

// add anchor time
void add_anchor_time(char* anchor_name,double anchor_time) 
{
    anchor_time_num += 1;
    realloc_string_array_object(pilot_trans_data->anchor_names,anchor_time_num+1);
    realloc_string_array_object(pilot_trans_data->anchor_times,anchor_time_num+1);
    store_string(anchor_name,pilot_trans_data->anchor_names[anchor_time_num-1]);
    store_string_for_num(anchor_time,pilot_trans_data->anchor_times[anchor_time_num-1]) ;
}

// start to record time
clock_t start_to_record_time() 
{
    clock_t starttime = clock();
    return starttime;
}

// end time
double end_time(clock_t starttime) 
{
    clock_t endtime = clock();
    double cpu_time_used = ((double) (endtime - starttime)) / CLOCKS_PER_SEC;
    return cpu_time_used;
}