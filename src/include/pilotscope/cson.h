/**
 * @file   cson.h
 * @author sun_chb@126.com
 */
#ifndef _CSON_H_
#define _CSON_H_

#include "stddef.h"

/**
 * @brief error code of parser.
 */
#define     ERR_NONE            (0)     /**< success */
#define     ERR_MEMORY          (-1)    /**< malloc failed */
#define     ERR_TYPE            (-2)    /**< type matching error */
#define     ERR_MISSING_FIELD   (-3)    /**< field not found */
#define     ERR_FORMAT          (-4)    /**< input json string format error */
#define     ERR_ARGS            (-5)    /**< args error */
#define     ERR_OVERFLOW        (-6)    /**< value overflow */

/**
 * @brief the type of json object.
 */
typedef enum {
    CSON_OBJECT,
    CSON_ARRAY,
    CSON_STRING,
    CSON_INTEGER,
    CSON_REAL,
    CSON_TRUE,
    CSON_FALSE,
    CSON_NULL
} cson_type;

typedef void*   cson_t;

/**
 * @brief define the function type of json parse/pack function group
 */
typedef cson_t      (*func_cson_object_get)(const cson_t object, const char* key);
typedef cson_type   (*func_cson_typeof)(cson_t object);
typedef cson_t      (*func_cson_loadb)(const char *buffer, size_t buflen);
typedef void        (*func_cson_decref)(cson_t object);
typedef const char* (*func_cson_string_value)(const cson_t object);
typedef size_t      (*func_cson_string_length)(const cson_t object);
typedef long long   (*func_cson_integer_value)(const cson_t object);
typedef double      (*func_cson_real_value)(const cson_t object);
typedef char        (*func_cson_bool_value)(const cson_t object);
typedef size_t      (*func_cson_array_size)(const cson_t object);
typedef cson_t      (*func_cson_array_get)(const cson_t object, size_t index);
typedef cson_t      (*func_cson_new)();
typedef char*       (*func_cson_to_string)(cson_t object);
typedef cson_t      (*func_cson_integer)(long long val);
typedef cson_t      (*func_cson_string)(const char* val);
typedef cson_t      (*func_cson_bool)(char val);
typedef cson_t      (*func_cson_real)(double val);
typedef cson_t      (*func_cson_array)();
typedef int         (*func_cson_array_add)(cson_t array, cson_t obj);
typedef int         (*func_cson_object_set_new)(cson_t rootObj, const char* field, cson_t obj);

/**
 * @brief define the cson interface
 */
typedef struct {
    func_cson_object_get cson_object_get;
    func_cson_typeof cson_typeof;
    func_cson_loadb cson_loadb;
    func_cson_decref cson_decref;
    func_cson_string_value cson_string_value;
    func_cson_string_length cson_string_length;
    func_cson_integer_value cson_integer_value;
    func_cson_real_value cson_real_value;
    func_cson_bool_value cson_bool_value;
    func_cson_array_size cson_array_size;
    func_cson_array_get cson_array_get;
    func_cson_new cson_object;
    func_cson_to_string cson_to_string;
    func_cson_integer cson_integer;
    func_cson_string cson_string;
    func_cson_bool cson_bool;
    func_cson_real cson_real;
    func_cson_array cson_array;
    func_cson_array_add cson_array_add;
    func_cson_object_set_new cson_object_set_new;
} cson_interface;

/**
 * @brief the description of property in struct.
 *
 * @TODO: Try to simplify the struct
 */
typedef struct reflect_item_t {
    const char*             field;                  /**< field */
    size_t                  offset;                 /**< offset of property */
    size_t                  size;                   /**< size of property */
    cson_type               type;                   /**< corresponding json type */
    const struct reflect_item_t*  reflect_tbl;      /**< must be specified when type is object or array */
    size_t                  arrayItemSize;          /**< size of per array item. must be specified when type is array */
    const char*             arrayCountField;        /**< field saving array size */
    int                     exArgs;                 /**< paser return failure when the field is not found and nullable equals to 0 */
} reflect_item_t;

extern const reflect_item_t integerReflectTbl[];
extern const reflect_item_t stringReflectTbl[];
extern const reflect_item_t boolReflectTbl[];
extern const reflect_item_t realReflectTbl[];

#define _ex_args_nullable       (0x01)
#define _ex_args_exclude_decode (0x02)
#define _ex_args_exclude_encode (0x04)
#define _ex_args_all            (_ex_args_nullable | _ex_args_exclude_decode | _ex_args_exclude_encode)

#define _offset(type, field)                                                (size_t)(&(((type*)0)->field))
#define _size(type, field)                                                  (sizeof(((type*)0)->field))
#define _property(type, field, jtype, tbl, nullable)                        {#field, _offset(type, field), _size(type, field), jtype, tbl, 0, NULL, nullable}
#define _property_end()                                                     {NULL, 0, 0, CSON_NULL, NULL, 0, NULL, 1}

/**
 * @brief Declaring integer properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 *
 */
#define _property_int(type, field)                                          _property(type, field, CSON_INTEGER, integerReflectTbl, _ex_args_nullable)

/**
 * @brief Declaring real properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 *
 */
#define _property_real(type, field)                                         _property(type, field, CSON_REAL, realReflectTbl, _ex_args_nullable)

/**
 * @brief Declaring bool properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 *
 */
#define _property_bool(type, field)                                         _property(type, field, CSON_TRUE, boolReflectTbl, _ex_args_nullable)

/**
 * @brief Declaring string properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 *
 */
#define _property_string(type, field)                                       _property(type, field, CSON_STRING, stringReflectTbl, _ex_args_nullable)

/**
 * @brief Declaring struct properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 * @param tbl: property description table of sub-struct
 *
 */
#define _property_obj(type, field, tbl)                                     _property(type, field, CSON_OBJECT, tbl, _ex_args_nullable)

/**
 * @brief Declaring array properties.
 *
 * @param type: type of struct
 * @param field: field name of properties
 * @param tbl: property description table of type of array
 * @param subType: type of array
 * @param count: property to save the array size
 *
 */
#define _property_array(type, field, tbl, subType, count)                   {#field, _offset(type, field), _size(type, field), CSON_ARRAY, tbl, sizeof(subType), #count, _ex_args_nullable}
#define _property_array_object(type, field, tbl, subType, count)            _property_array(type, field, tbl, subType, count)
#define _property_array_int(type, field, subType, count)                    _property_array(type, field, integerReflectTbl, subType, count)
#define _property_array_string(type, field, subType, count)                 _property_array(type, field, stringReflectTbl, subType, count)
#define _property_array_real(type, field, subType, count)                   _property_array(type, field, realReflectTbl, subType, count)
#define _property_array_bool(type, field, subType, count)                   _property_array(type, field, boolReflectTbl, subType, count)

/**
 * @brief nonull definitions. parser will stop and return error code when field not found which declared whit it.
 *
 * @param refer to comment of nullable definition
 */
#define _property_int_nonull(type, field)                                   _property(type, field, CSON_INTEGER, NULL, 0)
#define _property_real_nonull(type, field)                                  _property(type, field, CSON_REAL, NULL, 0)
#define _property_bool_nonull(type, field)                                  _property(type, field, CSON_TRUE, NULL, 0)
#define _property_string_nonull(type, field)                                _property(type, field, CSON_STRING, NULL, 0)
#define _property_obj_nonull(type, field, tbl)                              _property(type, field, CSON_OBJECT, tbl, 0)
#define _property_array_nonull(type, field, tbl, subType, count)            {#field, _offset(type, field), _size(type, field), CSON_ARRAY, tbl, sizeof(subType), #count, 0}
#define _property_array_object_nonull(type, field, tbl, subType, count)     _property_array_nonull(type, field, tbl, subType, count)
#define _property_array_int_nonull(type, field, subType, count)             _property_array_nonull(type, field, integerReflectTbl, subType, count)
#define _property_array_string_nonull(type, field, subType, count)          _property_array_nonull(type, field, stringReflectTbl, subType, count)
#define _property_array_real_nonull(type, field, subType, count)            _property_array_nonull(type, field, realReflectTbl, subType, count)
#define _property_array_bool_nonull(type, field, subType, count)            _property_array_nonull(type, field, boolReflectTbl, subType, count)

/**
 * @brief nonull definitions. parser will stop and return error code when field not found which declared whit it.
 *
 * @param refer to comment of nullable definition
 * @param args opptional with _ex_args_nullable(0x01) _ex_args_exclude_decode(0x02) _ex_args_exclude_encode(0x04)
 */
#define _property_int_ex(type, field, args)                                 _property(type, field, CSON_INTEGER, NULL, args)
#define _property_real_ex(type, field, args)                                _property(type, field, CSON_REAL, NULL, args)
#define _property_bool_ex(type, field, args)                                _property(type, field, CSON_TRUE, NULL, args)
#define _property_string_ex(type, field, args)                              _property(type, field, CSON_STRING, NULL, args)
#define _property_obj_ex(type, field, tbl, args)                            _property(type, field, CSON_OBJECT, tbl, args)
#define _property_array_ex(type, field, tbl, subType, count, args)          {#field, _offset(type, field), _size(type, field), CSON_ARRAY, tbl, sizeof(subType), #count, args}
#define _property_array_object_ex(type, field, tbl, subType, count, args)   _property_array_ex(type, field, tbl, subType, count)
#define _property_array_int_ex(type, field, subType, count, args)           _property_array_ex(type, field, integerReflectTbl, subType, count)
#define _property_array_string_ex(type, field, subType, count, args)        _property_array_ex(type, field, stringReflectTbl, subType, count)
#define _property_array_real_ex(type, field, subType, count, args)          _property_array_ex(type, field, realReflectTbl, subType, count)
#define _property_array_bool_ex(type, field, subType, count, args)          _property_array_ex(type, field, boolReflectTbl, subType, count)

/**
 * @brief function type of csonLoopProperty.
 *
 * @param obj: pointer of property.
 * @param tbl: property of field.
 *
 * @return void*(reserved).
 */
typedef void* (*loop_func_t)(void* pData, const reflect_item_t* tbl);

/**
 * @brief loop all property and process property by @func
 *
 * @param obj: object to be operated.
 * @param tbl: property of field.
 * @param func: callback
 *
 * @return void.
 */
void    csonLoopProperty(void* obj, const reflect_item_t* tbl, loop_func_t func);

/**
 * @brief convert json string to struct object.
 *
 * @param jstr: json string
 * @param output: target object
 * @param tbl: property table of output.
 *
 * @return ERR_NONE on success, otherwise failed.
 */
int csonJsonStr2Struct(const char* jstr, void* output, const reflect_item_t* tbl);

/**
 * @brief convert struct object to json string.
 *
 * @param jstr: output json string
 * @param output: input struct object
 * @param tbl: property table of input.
 *
 * @return ERR_NONE on success, otherwise failed.
 */
int csonStruct2JsonStr(char** jstr, void* input, const reflect_item_t* tbl);

/**
 * @brief Iterative output properties of data
 *
 * @param pData: struct object
 * @param tbl: property table of input.
 *
 * @return void.
 */
void csonPrintProperty(void* pData, const reflect_item_t* tbl);

/**
 * @brief Iterative free pointer of data
 *
 * @param pData: struct object
 * @param tbl: property table of input.
 *
 * @return void.
 */
void csonFreePointer(void* list, const reflect_item_t* tbl);

#endif