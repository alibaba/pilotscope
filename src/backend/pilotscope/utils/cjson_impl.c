/**
 * @file   cjson_impl.c
 * @author sun_chb@126.com
 */
#include "pilotscope/cJSON.h"
#include "pilotscope/cson.h"
#include "string.h"
#include "stdio.h"

cson_t  cjson_impl_object_get(const cson_t object, const char* key){
    return cJSON_GetObjectItem((cJSON*)object, key);
}

cson_type cjson_impl_typeof(cson_t object){
    switch(((cJSON*)object)->type){
        case cJSON_Invalid:
        case cJSON_NULL:
            return CSON_NULL;
        case cJSON_False:
            return CSON_FALSE;
        case cJSON_True:
            return CSON_TRUE;
        case cJSON_Number:
            return CSON_REAL;
        case cJSON_String:
        case cJSON_Raw:
            return CSON_STRING;
        case cJSON_Array:
            return CSON_ARRAY;
        case cJSON_Object:
            return CSON_OBJECT;
        default:
            return CSON_NULL;
    }
}

cson_t cjson_impl_loadb(const char *buffer, size_t buflen){
    cson_t ret = NULL;
    ret = cJSON_Parse(buffer);
    if(!ret){
        printf("parse stop with:%s\n", cJSON_GetErrorPtr());
    }
    return ret;
}

void cjson_impl_decref(cson_t object){
    cJSON_Delete((cJSON*)object);
}

const char *cjson_impl_string_value(const cson_t object){
    return cJSON_GetStringValue((cJSON*)object);
}

size_t cjson_impl_string_length(const cson_t object){
    return strlen(cJSON_GetStringValue((cJSON*)object));
}

long long cjson_impl_integer_value(const cson_t object){
    return ((cJSON*)object)->valueint;
}

double cjson_impl_real_value(const cson_t object){
    return ((cJSON*)object)->valuedouble;
}

char cjson_impl_bool_value(const cson_t object){
    return ((cJSON*)object)->type == cJSON_True;
}

size_t cjson_impl_array_size(const cson_t object){
    return cJSON_GetArraySize((cJSON*)object);
}

cson_t cjson_impl_array_get(const cson_t object, size_t index){
    return cJSON_GetArrayItem((cJSON*)object, index);
}

cson_t cjson_impl_new(){
    return cJSON_CreateObject();
}

char* cjson_impl_to_string(cson_t object){
    return cJSON_PrintUnformatted((cJSON*)object);
}

cson_t cjson_impl_integer(long long val){
    cJSON* tmp = cJSON_CreateNumber(0);
    cJSON_SetNumberValue(tmp, val);
    return tmp;
}

cson_t cjson_impl_string(const char* val){
    return cJSON_CreateString(val);
}

cson_t cjson_impl_bool(char val){
    return cJSON_CreateBool(val);
}
cson_t cjson_impl_real(double val){
    return cJSON_CreateNumber(val);
}

cson_t cjson_impl_array(){
    return cJSON_CreateArray();
}

int cjson_impl_array_add(cson_t array, cson_t obj){
    cJSON_AddItemToArray((cJSON*)array, (cJSON*)obj);
    return 0;
}

int cjson_impl_object_set_new(cson_t rootObj, const char* field, cson_t obj){
    cJSON_AddItemToObject((cJSON*)rootObj, field, (cJSON*)obj);
    return 0;
}

cson_interface csomImpl = {
    cjson_impl_object_get,
    cjson_impl_typeof,
    cjson_impl_loadb,
    cjson_impl_decref,
    cjson_impl_string_value,
    cjson_impl_string_length,
    cjson_impl_integer_value,
    cjson_impl_real_value,
    cjson_impl_bool_value,
    cjson_impl_array_size,
    cjson_impl_array_get,
    cjson_impl_new,
    cjson_impl_to_string,
    cjson_impl_integer,
    cjson_impl_string,
    cjson_impl_bool,
    cjson_impl_real,
    cjson_impl_array,
    cjson_impl_array_add,
    cjson_impl_object_set_new
};
