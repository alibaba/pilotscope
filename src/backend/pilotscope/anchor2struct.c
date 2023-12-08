/*-------------------------------------------------------------------------
 *
 * anchor2struct.c
 *	  Routines to pares json to struct
 *
 * Pointers of anchor structs、pilotscope data struct and enumerate type:
 *      subquery_card_pull_anchor
 *      card_push_anchor
 *      execution_time_pull_anchor
 *      record_pull_anchor
 *      pilot_trans_data
 *      ANCHOR_NAME
 * 
 * Some global vars are used during parsing json and processing anchors:
 *      anchor_num
 *      subquery_count
 *      enableTerminate
 *      enableSend
 *      enablePilotscope
 *      port
 *      host
 * 
 * Some reflection tables are used in transforming json to strut wih the help
 * of "cson.h":
 *      Subquery_Card_Fetcher_Anchor_ref_tbl
 *      Card_Replace_Anchor_ref_tbl
 *      Execution_Time_Fetch_Anchor_ref_tbl
 *      Record_Fetch_Anchor_ref_tbl
 * 
 * Here, we init some varibales and structs、transform json to struct、transform struct
 * to json and store some data of anchors into hashtable in order to deal with some
 * special anchors.
 * 
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * -------------------------------------------------------------------------
 */

#include "pilotscope/anchor2struct.h"
#include <time.h>

/*
 * Change the value of ANCHOR_NAME according to anchorname.
 */
#define set_anchor_name_for_enu(name,enu_value) \
    if(strcmp(anchorname,name) == 0) \
    {\
        *ANCHOR_NAME = enu_value; \
        return;\
    }

/*
 * get json from cjson object
 */
#define get_json_from_cjson(root) cJSON_Print(root);

/*
 * free palloc
 */
#define free_palloc(var_name) if(var_name!=NULL)\
    {\
        pfree(var_name);\
        var_name = NULL;\
    }

/*
 * free malloc
 */
#define free_malloc(var_name) if(var_name!=NULL)\
    {\
        free(var_name);\
        var_name = NULL;\
    }

static char* pilottransdata_to_json();
static void put_aimodel_subquery2card(Hashtable* table, const char* key, const char* value);
static void cJSON_AddStringArrayToObject(cJSON*root,char* array_name,char** array,int array_size);
static void store_array_num_for_pilottransdata();
static double get_curr_timestamp();
static void free_all_struct();

/*
 * Some global vars relative to anchor operation.
 */
SubqueryCardPullAnchor *subquery_card_pull_anchor;
CardPushAnchor *card_push_anchor;
ExecutionTimePullAnchor *execution_time_pull_anchor ;
RecordPullAnchor *record_pull_anchor;
PilotTransData *pilot_trans_data;
AnchorName* ANCHOR_NAME;

int anchor_num;
int subquery_count;
int enableTerminate;
int enableSend;
int enablePilotscope;
int port;
char* host;
int push_card_cnt;

/*
 * Define some reflection tables(refer to 'cson'). We need to state every varibles in the struct.
 * Note that the type '_property_int_ex' are not included in struct but need to be stated 
 * according to 'cson'. More information about reflection tables is in public document about 'cson'
 */
reflect_item_t Subquery_Card_Fetcher_Anchor_ref_tbl[] = {
    _property_bool(SubqueryCardPullAnchor, enable),
    _property_string(SubqueryCardPullAnchor, name),
    _property_end()
};

reflect_item_t Card_Replace_Anchor_ref_tbl[] = {
    _property_bool(CardPushAnchor, enable),
    _property_string(CardPushAnchor, name),

    _property_int_ex(CardPushAnchor, subquery_num, _ex_args_all),
    _property_array_string(CardPushAnchor, subquery, char*, subquery_num),

    _property_int_ex(CardPushAnchor, card_num, _ex_args_all),
    _property_array_real(CardPushAnchor, card, double, card_num),
    _property_end()
};

reflect_item_t Execution_Time_Fetch_Anchor_ref_tbl[] = {
    _property_bool(ExecutionTimePullAnchor, enable),
    _property_string(ExecutionTimePullAnchor, name),
    _property_end()
};

reflect_item_t Record_Fetch_Anchor_ref_tbl[] = {
    _property_bool(RecordPullAnchor, enable),
    _property_string(RecordPullAnchor, name),
    _property_end()
};

/*
 * Init some vars here including pilot_trans_data、ANCHOR_NAME and other vars in
 * respect to the parsing json and processing anchors. 
 */
 void init_some_vars()
 {  
    // init pilottransdata
    init_struct(pilot_trans_data,PilotTransData)

    // init other vars
    AnchorName an                   = UNKNOWN_ANCHOR;
    ANCHOR_NAME                     = &an;
    anchor_num                      = 0;
    enableSend                      = 1;
    enableTerminate                 = false;
    enablePilotscope                = 1;
    subquery_count                  = 0;
    host                            = NULL;
    port                            = 8888;
    push_card_cnt                   = 0;
 }

/*
 * Change the value of ANCHOR_NAME according to anchorname.
 */
void anchorname_to_enu(char* anchorname)
{
    set_anchor_name_for_enu("SUBQUERY_CARD_PULL_ANCHOR", SUBQUERY_CARD_PULL_ANCHOR);
    set_anchor_name_for_enu("CARD_PUSH_ANCHOR", CARD_PUSH_ANCHOR);
    set_anchor_name_for_enu("EXECUTION_TIME_PULL_ANCHOR", EXECUTION_TIME_PULL_ANCHOR);
    set_anchor_name_for_enu("RECORD_PULL_ANCHOR", RECORD_PULL_ANCHOR);
    set_anchor_name_for_enu("PHYSICAL_PLAN_PULL_ANCHOR", PHYSICAL_PLAN_PULL_ANCHOR);
    set_anchor_name_for_enu("COST_PUSH_ANCHOR", COST_PUSH_ANCHOR);
    set_anchor_name_for_enu("HINT_PUSH_ANCHOR", HINT_PUSH_ANCHOR);
    *ANCHOR_NAME = UNKNOWN_ANCHOR;
}

/*
 * Transform pilotscopedata struct to json one by one with the help of 'cjson'.
 * Some people may be confused that why we don't use the reflection tables in 
 * 'cson'. What we can tell you is that there is some bugs when transform struct
 * to json with reflection tables by cson when some of the vars of struct is null. 
 * So, we just transform each item one by one wit the help of 'cjson'. Noting that,
 * we can modify the codes if we extend the vars in piotscopedata struct.
 */
static char* pilottransdata_to_json() 
{     
    cJSON* root = cJSON_CreateObject();    
    if (root == NULL) 
    {   
        return NULL;    
    }

    // add each single element
    cJSON_AddStringToObject(root, "sql", pilot_trans_data->sql);
    cJSON_AddStringToObject(root, "physical_plan", pilot_trans_data->physical_plan);
    cJSON_AddStringToObject(root, "logical_plan", pilot_trans_data->logical_plan);
    cJSON_AddStringToObject(root, "execution_time", pilot_trans_data->execution_time);
    cJSON_AddStringToObject(root, "tid", pilot_trans_data->tid);

    //  add array element to json from struct
    cJSON_AddStringArrayToObject(root,"subquery",pilot_trans_data->subquery,pilot_trans_data->subquery_num);
    cJSON_AddStringArrayToObject(root,"card",pilot_trans_data->card,pilot_trans_data->card_num);

    // get json
    char* json = get_json_from_cjson(root);    
    cJSON_Delete(root);    

    return json;
}

/* 
 * Here,we will send data back if "enableSend == 1" and terminate the program if "enableTerminate == 1"
 */
void end_anchor()
{ 
    /*
     * Store anchor_num 、anchortime_num、card_num and subquery_num which are aligned to the anchor structs. Note that we will not
     * send this vars back. 
     */
    store_array_num_for_pilottransdata();  
    elog(INFO,"Ready to end anchors!");

    /*
     * If "enableSend == 1", we will ßfirst record the current moment as the send time and then transform
     * struct to json in struct_to_json. Finally, the data will be sent to python side.
     */
    if(enableSend == 1)
    {
        // send
        char* string_of_pilottransdata = pilottransdata_to_json();
        send_and_receive(string_of_pilottransdata);

        // free
        free_malloc(string_of_pilottransdata); 
    }
    else
    {
        elog(INFO,"No pull anchor and no need to send!");
    }

    // free all the struct pointers after sending and set them to null to avoid being wild pointers
    free_all_struct();  

    /*
     * If enableTerminate == 1, we will terminate the program and back to psql. Note that we don't close
     * the session but just back to psql with the help of ereport.
     */
    if(enableTerminate == 1)
    {
        back_to_psql("PilotScopePullEnd:Back to psql!");
    }
    else
    {
        elog(INFO,"No need to terminate and the program will go on!");
    }
}

/*
 * Some hash operation for card_push_anchor. Including store the whoe、get one and put one.
 * Note that the size of table are advised to set as  the square of the card_num in order to
 * avoid the hash confict.
 */
/** temporarily remove hashtable **/
/*
// store_aimodel_subquery2card
 void store_aimodel_subquery2card()
{
    // avoid hash confict
    table_size = card_push_anchor->card_num * card_push_anchor->card_num;
    table      = create_hashtable();

    for(int i = 0;i<card_push_anchor->card_num;i++)
    {
        char card[CHAR_LEN_FOR_NUM];
        sprintf(card,"%.3f",card_push_anchor->card[i]);
        put_aimodel_subquery2card(table, card_push_anchor->subquery[i], card);
    }
}

// get_card_from_push_anchor
char* get_card_from_push_anchor(Hashtable* table, const char* key)
{
    char* card = get(table, key);
    if(card == NULL)
    {
        return NULL;
    }
    else
    {
        return card;
    }
}
*/

double get_next_card_from_push_anchor() {
    return card_push_anchor->card[push_card_cnt++];
}

/** temporarily remove hashtable **/
/*
// put_aimodel_subquery2card
static void put_aimodel_subquery2card(Hashtable* table, const char* key, const char* value)
{
    put(table, key, value);
    
}
*/
// add string array to cjson object
static void cJSON_AddStringArrayToObject(cJSON*root,char* array_name,char** array,int array_size)
{
    if (array_size > 0 && array != NULL) 
    { 
        cJSON* cjson_array = cJSON_CreateArray(); 
        for (size_t i = 0; i < array_size; i++) { 
            if (array[i] != NULL) 
            { 
                cJSON_AddItemToArray(cjson_array, cJSON_CreateString(array[i])); 
            } 
        } 
        cJSON_AddItemToObject(root, array_name, cjson_array); 
    }
    return;
}

// store array num for pilottransdata
static void store_array_num_for_pilottransdata()
{
    pilot_trans_data->card_num = subquery_count;
    pilot_trans_data->subquery_num = subquery_count;
    return ;
}

// free all struct
static void free_all_struct()
{
    free_palloc(pilot_trans_data);
    free_palloc(subquery_card_pull_anchor);
    free_palloc(card_push_anchor);
    free_palloc(execution_time_pull_anchor);
    free_palloc(record_pull_anchor);
    /** temporarily remove hashtable **/
    //free_palloc(table);
    return;
}