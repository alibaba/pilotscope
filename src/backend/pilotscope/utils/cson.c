/**
 * @file   cson.c
 * @author sun_chb@126.com
 */
#include "pilotscope/cson.h"
#include "stdio.h"
#include "stdlib.h"
#include "stddef.h"
#include "limits.h"
#include "string.h"

extern cson_interface csomImpl;

#define cson_object_get csomImpl.cson_object_get
#define cson_typeof csomImpl.cson_typeof
#define cson_loadb csomImpl.cson_loadb
#define cson_decref csomImpl.cson_decref
#define cson_string_value csomImpl.cson_string_value
#define cson_string_length csomImpl.cson_string_length
#define cson_integer_value csomImpl.cson_integer_value
#define cson_real_value csomImpl.cson_real_value
#define cson_bool_value csomImpl.cson_bool_value
#define cson_array_size csomImpl.cson_array_size
#define cson_array_get csomImpl.cson_array_get
#define cson_object csomImpl.cson_object
#define cson_to_string csomImpl.cson_to_string
#define cson_integer csomImpl.cson_integer
#define cson_string csomImpl.cson_string
#define cson_bool csomImpl.cson_bool
#define cson_real csomImpl.cson_real
#define cson_array csomImpl.cson_array
#define cson_array_add csomImpl.cson_array_add
#define cson_object_set_new csomImpl.cson_object_set_new
#define cson_is_number(type) (type == CSON_REAL || type == CSON_INTEGER)
#define cson_is_bool(type)    (type == CSON_TRUE || type == CSON_FALSE)

const reflect_item_t integerReflectTbl[] = {
    {"0Integer", 0, sizeof(int), CSON_INTEGER, NULL, 0, NULL, 1},
    {}
};

const reflect_item_t stringReflectTbl[] = {
    {"0String", 0, sizeof(char*), CSON_STRING, NULL, 0, NULL, 1},
    {}
};

const reflect_item_t realReflectTbl[] = {
    {"0Real", 0, sizeof(double), CSON_REAL, NULL, 0, NULL, 1},
    {}
};

const reflect_item_t boolReflectTbl[] = {
    {"0Bool", 0, sizeof(int), CSON_TRUE, NULL, 0, NULL, 1},
    {}
};

/*
 *  reflecter functions
 */
static const reflect_item_t* getReflexItem(const char* field, const reflect_item_t* tbl, int* pIndex);
static void* csonGetProperty(void* obj, const char* field, const reflect_item_t* tbl, int* pIndex);
static void csonSetProperty(void* obj, const char* field, void* data, const reflect_item_t* tbl);
static void csonSetPropertyFast(void* obj, const void* data, const reflect_item_t* tbl);

/*
 *  integer util functions
 */
typedef union {
    char c;
    short s;
    int i;
    long long l;
} integer_val_t;

static long long getIntegerValueFromPointer(void* ptr, int size);
static int getIntegerValue(cson_t jo_tmp, int size, integer_val_t* i);
static int convertInteger(long long val, int size, integer_val_t* i);
static int checkInteger(long long val, int size);

/*
 * packer functions
 */
typedef int (*json_pack_proc)(void* input, const reflect_item_t* tbl, int index, cson_t* obj);

static int getJsonObject(void* input, const reflect_item_t* tbl, int index, cson_t* obj);
static int getJsonArray(void* input, const reflect_item_t* tbl, int index, cson_t* obj);
static int getJsonString(void* input, const reflect_item_t* tbl, int index, cson_t* obj);
static int getJsonInteger(void* input, const reflect_item_t* tbl, int index, cson_t* obj);
static int getJsonReal(void* input, const reflect_item_t* tbl, int index, cson_t* obj);
static int getJsonBool(void* input, const reflect_item_t* tbl, int index, cson_t* obj);

json_pack_proc jsonPackTbl[] = {
    getJsonObject,
    getJsonArray,
    getJsonString,
    getJsonInteger,
    getJsonReal,
    getJsonBool,
    getJsonBool,
    NULL
};

static int csonStruct2JsonObj(cson_t obj, void* input, const reflect_item_t* tbl);

/*
 * parser functions
 */
typedef int (*json_obj_proc)(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);

static int parseJsonObject(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonArray(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonString(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonInteger(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonReal(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonBool(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);

json_obj_proc jsonObjProcTbl[] = {
    parseJsonObject,
    parseJsonArray,
    parseJsonString,
    parseJsonInteger,
    parseJsonReal,
    parseJsonBool,
    parseJsonBool,
    NULL
};

static int parseJsonObjectDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonArrayDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonStringDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonIntegerDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);
static int parseJsonRealDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index);

json_obj_proc jsonObjDefaultTbl[] = {
    parseJsonObjectDefault,
    parseJsonArrayDefault,
    parseJsonStringDefault,
    parseJsonIntegerDefault,
    parseJsonRealDefault,
    parseJsonIntegerDefault,
    parseJsonIntegerDefault,
    NULL
};

static int csonJsonObj2Struct(cson_t jo, void* output, const reflect_item_t* tbl);

int csonStruct2JsonStr(char** jstr, void* input, const reflect_item_t* tbl)
{
    cson_t jsonPack = cson_object();

    if (!jsonPack) return ERR_MEMORY;

    int ret = csonStruct2JsonObj(jsonPack, input, tbl);

    if (ret == ERR_NONE) {
        char* dumpStr = cson_to_string(jsonPack);
        if (dumpStr == NULL) {
            ret = ERR_MEMORY;
        } else {
            *jstr = dumpStr;
        }
    }

    cson_decref(jsonPack);
    return ret;
}

int csonStruct2JsonObj(cson_t obj, void* input, const reflect_item_t* tbl)
{
    int i = 0;
    int ret = ERR_NONE;

    if (!obj || !input || !tbl) return ERR_ARGS;

    while (1) {
        if (tbl[i].field == NULL) break;

        if(tbl[i].exArgs & _ex_args_exclude_encode){
            i++;
            continue;
        }

        cson_t joTmp = NULL;
        int jsonType = tbl[i].type;

        if (jsonPackTbl[jsonType] != NULL) {
            ret = jsonPackTbl[jsonType](input, tbl, i, &joTmp);
        }

        if (ret != ERR_NONE ) {
            printf("!!!!pack error on field:%s, cod=%d!!!!\n", tbl[i].field, ret);
            if (!(tbl[i].exArgs & _ex_args_nullable)) return ret;
        } else {
            cson_object_set_new(obj, tbl[i].field, joTmp);
        }

        i++;
    }

    return ERR_NONE;
}

int getJsonInteger(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    if (tbl[index].size != sizeof(char) &&
        tbl[index].size != sizeof(short) &&
        tbl[index].size != sizeof(int) &&
        tbl[index].size != sizeof(long long)) {
        printf("Unsupported size(=%ld) of integer.\n", tbl[index].size);
        printf("Please check if the type of field %s in char/short/int/long long!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    void* pSrc = (void*)((char*)input + tbl[index].offset);

    long long val = getIntegerValueFromPointer(pSrc, tbl[index].size);

    *obj = cson_integer(val);

    return ERR_NONE;
}

int getJsonString(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    void* pSrc = (void*)((char*)input + tbl[index].offset);

    if (*((char**)pSrc) == NULL) return ERR_MISSING_FIELD;

    *obj = cson_string(*((char**)pSrc));
    return ERR_NONE;
}

int getJsonObject(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    void* pSrc = (void*)((char*)input + tbl[index].offset);
    cson_t jotmp = cson_object();
    int ret = csonStruct2JsonObj(jotmp, pSrc, tbl[index].reflect_tbl);

    if (ret == ERR_NONE) {
        *obj = jotmp;
    } else {
        cson_decref(jotmp);
    }

    return ret;
}

int getJsonArray(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    int ret = ERR_NONE;
    int countIndex = -1;
    char* pSrc = (*(char**)((char*)input + tbl[index].offset));

    if (pSrc == NULL) return ERR_MISSING_FIELD;

    void* ptr = csonGetProperty(input, tbl[index].arrayCountField, tbl, &countIndex);

    if (ptr == NULL || countIndex == -1) {
        return ERR_MISSING_FIELD;
    }
    long long size = getIntegerValueFromPointer(ptr, tbl[countIndex].size);

    cson_t joArray = cson_array();

    long long successCount = 0;

    for (long long i = 0; i < size; i++) {
        cson_t jotmp;

        if (tbl[index].reflect_tbl[0].field[0] == '0') {    /* field start with '0' mean basic types. */
            ret = jsonPackTbl[tbl[index].reflect_tbl[0].type](pSrc + (i * tbl[index].arrayItemSize), tbl[index].reflect_tbl, 0, &jotmp);
        } else {
            jotmp = cson_object();
            ret = csonStruct2JsonObj(jotmp, pSrc + (i * tbl[index].arrayItemSize), tbl[index].reflect_tbl);
        }

        if (ret == ERR_NONE) {
            successCount++;
            cson_array_add(joArray, jotmp);
        } else {
            printf("create array item faild.\n");
            cson_decref(jotmp);
        }
    }

    if (successCount == 0) {
        cson_decref(joArray);
        return ERR_MISSING_FIELD;
    } else {
        *obj = joArray;
        return ERR_NONE;
    }

    return ret;
}

int getJsonReal(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    if (tbl[index].size != sizeof(double)) {
        printf("Unsupported size(=%ld) of real.\n", tbl[index].size);
        printf("Please check if the type of field %s is double!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    void* pSrc = (void*)((char*)input + tbl[index].offset);
    *obj = cson_real(*((double*)pSrc));
    return ERR_NONE;
}

int getJsonBool(void* input, const reflect_item_t* tbl, int index, cson_t* obj)
{
    if (tbl[index].size != sizeof(char) &&
        tbl[index].size != sizeof(short) &&
        tbl[index].size != sizeof(int) &&
        tbl[index].size != sizeof(long long)) {
        printf("Unsupported size(=%ld) of bool.\n", tbl[index].size);
        printf("Please check if the type of field %s in char/short/int/long long!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    void* pSrc = (void*)((char*)input + tbl[index].offset);

    if (tbl[index].size == sizeof(char)) {
        *obj = cson_bool(*((char*)pSrc));
    } else if (tbl[index].size == sizeof(short)) {
        *obj = cson_bool(*((short*)pSrc));
    } else if (tbl[index].size == sizeof(int)) {
        *obj = cson_bool(*((int*)pSrc));
    } else {
        *obj = cson_bool(*((long long*)pSrc));
    }

    return ERR_NONE;
}


int csonJsonStr2Struct(const char* jstr, void* output, const reflect_item_t* tbl)
{
    /* load json string */
    cson_t jo = cson_loadb(jstr, strlen(jstr));

    if (!jo) return ERR_FORMAT;

    int ret = csonJsonObj2Struct(jo, output, tbl);
    cson_decref(jo);

    return ret;
}

int csonJsonObj2Struct(cson_t jo, void* output, const reflect_item_t* tbl)
{
    if (!jo || !output || !tbl) return ERR_ARGS;

    for (int i = 0;; i++) {
        int ret = ERR_NONE;
        if (tbl[i].field == NULL) break;
        
        if(tbl[i].exArgs & _ex_args_exclude_decode){
            continue;
        }

        cson_t jo_tmp = cson_object_get(jo, tbl[i].field);

        if (jo_tmp == NULL) {
            ret = ERR_MISSING_FIELD;
        } else {

            int jsonType = cson_typeof(jo_tmp);

            if (jsonType == tbl[i].type ||
                (cson_is_number(cson_typeof(jo_tmp)) && cson_is_number(tbl[i].type)) ||
                (cson_is_bool(cson_typeof(jo_tmp)) && cson_is_bool(tbl[i].type))) {
                if (jsonObjProcTbl[tbl[i].type] != NULL) {
                    ret = jsonObjProcTbl[tbl[i].type](jo_tmp, output, tbl, i);
                }
            } else {
                ret = ERR_TYPE;
            }
        }

        if (ret != ERR_NONE ) {
            printf("!!!!parse error on field:%s, cod=%d!!!!\n", tbl[i].field, ret);
            jsonObjDefaultTbl[tbl[i].type](NULL, output, tbl, i);
            if (!(tbl[i].exArgs & _ex_args_nullable)) return ret;
        }
    }

    return ERR_NONE;
}

int parseJsonString(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    const char* tempstr = cson_string_value(jo_tmp);
    if (NULL != tempstr) {
        char* pDst = (char*)malloc(strlen(tempstr) + 1);
        if (pDst == NULL) {
            return ERR_MEMORY;
        }
        strcpy(pDst, tempstr);
        csonSetPropertyFast(output, &pDst, tbl + index);

        return ERR_NONE;
    }

    return ERR_MISSING_FIELD;
}

int parseJsonInteger(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    int ret;
    integer_val_t value;
    ret = getIntegerValue(jo_tmp, tbl[index].size, &value);

    if (ret != ERR_NONE) {
        printf("Get integer failed!field:%s,errno:%d.\n", tbl[index].field, ret);
    } else {
        csonSetPropertyFast(output, &value, tbl + index);
    }

    return ret;
}

int parseJsonObject(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    return csonJsonObj2Struct(jo_tmp, (char*)output + tbl[index].offset, tbl[index].reflect_tbl);
}

int parseJsonArray(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    size_t arraySize = cson_array_size(jo_tmp);

    if (arraySize == 0) {
        csonSetProperty(output, tbl[index].arrayCountField, &arraySize, tbl);
        return ERR_NONE;
    }

    int countIndex = -1;
    csonGetProperty(output, tbl[index].arrayCountField, tbl, &countIndex);

    if (countIndex == -1) {
        return ERR_MISSING_FIELD;
    }

    char* pMem = (char*)malloc(arraySize * tbl[index].arrayItemSize);
    if (pMem == NULL) return ERR_MEMORY;

    memset(pMem, 0, arraySize * tbl[index].arrayItemSize);

    long long successCount = 0;
    for (size_t j = 0; j < arraySize; j++) {
        cson_t item = cson_array_get(jo_tmp, j);
        if (item != NULL) {
            int ret;

            if (tbl[index].reflect_tbl[0].field[0] == '0') {    /* field start with '0' mean basic types. */
                ret = jsonObjProcTbl[tbl[index].reflect_tbl[0].type](item, pMem + (successCount * tbl[index].arrayItemSize), tbl[index].reflect_tbl, 0);
            } else {
                ret = csonJsonObj2Struct(item, pMem + (successCount * tbl[index].arrayItemSize), tbl[index].reflect_tbl);
            }

            if (ret == ERR_NONE) {
                successCount++;
            }
        }
    }

    integer_val_t val;
    if (convertInteger(successCount, tbl[countIndex].size, &val) != ERR_NONE) {
        successCount = 0;
    }

    if (successCount == 0) {
        csonSetPropertyFast(output, &successCount, tbl + countIndex);
        free(pMem);
        pMem = NULL;
        csonSetPropertyFast(output, &pMem, tbl + index);
        return ERR_MISSING_FIELD;
    } else {
        csonSetPropertyFast(output, &val, tbl + countIndex);
        csonSetPropertyFast(output, &pMem, tbl + index);
        return ERR_NONE;
    }
}

int parseJsonReal(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    if (tbl[index].size != sizeof(double)) {
        printf("Unsupported size(=%ld) of real.\n", tbl[index].size);
        printf("Please check if the type of field %s is double!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    double temp;
    if (cson_typeof(jo_tmp) == CSON_REAL) {
        temp = cson_real_value(jo_tmp);
    } else {
        temp = cson_integer_value(jo_tmp);
    }

    csonSetPropertyFast(output, &temp, tbl + index);
    return ERR_NONE;
}

int parseJsonBool(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    int ret;
    integer_val_t value;
    ret = getIntegerValue(jo_tmp, tbl[index].size, &value);
    if (ret != ERR_NONE) {
        printf("Get integer failed!field:%s,errno:%d.\n", tbl[index].field, ret);
    } else {
        csonSetPropertyFast(output, &value, tbl + index);
    }
    return ret;
}

int parseJsonObjectDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    int i = 0;
    while (1) {
        if (tbl[i].reflect_tbl[i].field == NULL) break;
        
        if(tbl[i].exArgs & _ex_args_exclude_decode){
            i++;
            continue;
        }

        jsonObjDefaultTbl[tbl[index].reflect_tbl[i].type](NULL, output, tbl[index].reflect_tbl, i);
        i++;
    };
    return ERR_NONE;
}

int parseJsonArrayDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    void* temp = NULL;
    csonSetPropertyFast(output, &temp, tbl + index);
    return ERR_NONE;
}

int parseJsonStringDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    char* temp = NULL;
    csonSetPropertyFast(output, &temp, tbl + index);
    return ERR_NONE;
}

int parseJsonIntegerDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    long long temp = 0;

    if (tbl[index].size != sizeof(char) &&
        tbl[index].size != sizeof(short) &&
        tbl[index].size != sizeof(int) &&
        tbl[index].size != sizeof(long long)) {
        printf("Unsupported size(=%ld) of bool.\n", tbl[index].size);
        printf("Please check if the type of field %s in char/short/int/long long!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    integer_val_t ret;
    convertInteger(temp, tbl[index].size, &ret);

    csonSetPropertyFast(output, &ret, tbl + index);
    return ERR_NONE;
}

int parseJsonRealDefault(cson_t jo_tmp, void* output, const reflect_item_t* tbl, int index)
{
    if (tbl[index].size != sizeof(double)) {
        printf("Unsupported size(=%ld) of bool.\n", tbl[index].size);
        printf("Please check if the type of field %s is double!\n", tbl[index].field);
        return ERR_OVERFLOW;
    }

    double temp = 0.0;
    csonSetPropertyFast(output, &temp, tbl + index);
    return ERR_NONE;
}


int getIntegerValue(cson_t jo_tmp, int size, integer_val_t* i)
{
    long long temp;

    if (cson_typeof(jo_tmp) == CSON_INTEGER) {
        temp = cson_integer_value(jo_tmp);
    } else if (cson_typeof(jo_tmp) == CSON_TRUE) {
        temp = 1;
    } else if (cson_typeof(jo_tmp) == CSON_FALSE) {
        temp = 0;
    } else if (cson_typeof(jo_tmp) == CSON_REAL) {
        double tempDouble = cson_real_value(jo_tmp);
        if (tempDouble > LLONG_MAX || tempDouble < LLONG_MIN) {
            return ERR_OVERFLOW;
        } else {
            temp = tempDouble;
        }
    } else {
        return ERR_ARGS;
    }

    return convertInteger(temp, size, i);
}

int convertInteger(long long val, int size, integer_val_t* i)
{
    int ret = checkInteger(val, size);

    if (ret != ERR_NONE) return ret;

    /* avoid error on big endian */
    if (size == sizeof(char)) {
        i->c = val;
    } else if (size == sizeof(short)) {
        i->s = val;
    } else if (size == sizeof(int)) {
        i->i = val;
    } else {
        i->l = val;
    }

    return ERR_NONE;
}

int checkInteger(long long val, int size)
{
    if (size != sizeof(char) &&
        size != sizeof(short) &&
        size != sizeof(int) &&
        size != sizeof(long long)) {
        return ERR_OVERFLOW;
    }

    if (size == sizeof(char) && (val > CHAR_MAX || val < CHAR_MIN)) {
        return ERR_OVERFLOW;
    } else if (size == sizeof(short) && (val > SHRT_MAX || val < SHRT_MIN)) {
        return ERR_OVERFLOW;
    } else if (size == sizeof(int)  && (val > INT_MAX || val < INT_MIN)) {
        return ERR_OVERFLOW;
    } else {
    }

    return ERR_NONE;
}

long long getIntegerValueFromPointer(void* ptr, int size)
{
    long long ret = 0;

    if (!ptr) return 0;

    if (size == sizeof(char)) {
        ret = *((char*)ptr);
    } else if (size == sizeof(short)) {
        ret = *((short*)ptr);
    } else if (size == sizeof(int)) {
        ret = *((int*)ptr);
    } else if (size == sizeof(long long)) {
        ret = *((long long*)ptr);
    } else {
        printf("Unsupported size(=%d) of integer.\n", size);
    }

    return ret;
}

/* reflect */
const reflect_item_t* getReflexItem(const char* field, const reflect_item_t* tbl, int* pIndex)
{
    const reflect_item_t* ret = NULL;

    for (int i = 0;; i++) {
        if (!(tbl[i].field)) break;
        if (strcmp(field, tbl[i].field) == 0) {
            ret = &(tbl[i]);

            if (pIndex) *pIndex = i;
            break;
        }
    }

    if (!ret) printf("Can not find field:%s.", field);

    return ret;
}

void* csonGetProperty(void* obj, const char* field, const reflect_item_t* tbl, int* pIndex)
{
    if (!(obj && field && tbl)) return NULL;
    const reflect_item_t* ret = getReflexItem(field, tbl, pIndex);

    if (!ret) return NULL;

    return (void*)((char*)obj + ret->offset);
}

void csonSetProperty(void* obj, const char* field, void* data, const reflect_item_t* tbl)
{
    if (!(obj && field && data && tbl)) return;

    const reflect_item_t* ret = getReflexItem(field, tbl, NULL);

    if (!ret) return;

    void* pDst = (void*)((char*)obj + ret->offset);
    memcpy(pDst, data, ret->size);
    return;
}

void csonSetPropertyFast(void* obj, const void* data, const reflect_item_t* tbl)
{
    if (!(obj && data && tbl)) return;

    void* pDst = (void*)((char*)obj + tbl->offset);
    memcpy(pDst, data, tbl->size);
    return;
}

void csonLoopProperty(void* pData, const reflect_item_t* tbl, loop_func_t func)
{
    int i = 0;
    while (1) {
        if (!tbl[i].field) break;

        char* pProperty = (char*)pData + tbl[i].offset;
        if (tbl[i].type == CSON_ARRAY) {
            int countIndex = -1;
            void* ptr = csonGetProperty(pData, tbl[i].arrayCountField, tbl, &countIndex);

            if (ptr == NULL || countIndex == -1) {
                continue;
            }
            long long size = getIntegerValueFromPointer(ptr, tbl[countIndex].size);

            for (long long j = 0; j < size; j++) {
                csonLoopProperty(*((char**)pProperty) + j * tbl[i].arrayItemSize, tbl[i].reflect_tbl, func);
            }
        } else if (tbl[i].type == CSON_OBJECT) {
            csonLoopProperty(pProperty, tbl[i].reflect_tbl, func);
        }

        func(pProperty, tbl + i);

        i++;
    }
}

static void* printPropertySub(void* pData, const reflect_item_t* tbl)
{
    if (tbl->type == CSON_ARRAY || tbl->type == CSON_OBJECT) return NULL;

    if (tbl->type == CSON_INTEGER || tbl->type == CSON_TRUE || tbl->type == CSON_FALSE) printf("%s:%d\n", tbl->field, *(int*)pData);

    if (tbl->type == CSON_REAL) printf("%s:%f\n", tbl->field, *(double*)pData);

    if (tbl->type == CSON_STRING) printf("%s:%s\n", tbl->field, *((char**)pData));

    return NULL;
}

static void* freePointerSub(void* pData, const reflect_item_t* tbl)
{
    if (tbl->type == CSON_ARRAY || tbl->type == CSON_STRING) {
        //printf("free field %s.\n", tbl->field);
        free(*(void**)pData);
        *(void**)pData = NULL;
    }
    return NULL;
}

void csonPrintProperty(void* pData, const reflect_item_t* tbl)
{
    /* 调用loopProperty迭代结构体中的属性,完成迭代输出属性值 */
    csonLoopProperty(pData, tbl, printPropertySub);
}

void csonFreePointer(void* list, const reflect_item_t* tbl)
{
    /* 调用loopProperty迭代结构体中的属性,释放字符串和数组申请的内存空间 */
    csonLoopProperty(list, tbl, freePointerSub);
}