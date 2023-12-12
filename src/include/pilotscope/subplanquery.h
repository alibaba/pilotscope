/*-------------------------------------------------------------------------
 *
 * subplanquery.h
 *	  prototypes for subplanquery.c.
 *
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * 
 *-------------------------------------------------------------------------
 */

#ifndef subplanquery__h
#define subplanquery__h

#include "pilotscope_config.h"
#include "postgres.h"
#include "utils/lsyscache.h"
#include "optimizer/pathnode.h"
#include "http.h"
#include "cJSON.h"
#include "commands/dbcommands.h"
#include "catalog/pg_type.h"
#include "catalog/pg_operator.h"
#include "pilotscope_config.h"

#include <math.h>
#include "access/amapi.h"
#include "access/htup_details.h"
#include "access/tsmapi.h"
#include "executor/executor.h"
#include "executor/nodeAgg.h"
#include "executor/nodeHash.h"
#include "miscadmin.h"
#include "nodes/makefuncs.h"
#include "nodes/nodeFuncs.h"
#include "optimizer/clauses.h"
#include "optimizer/cost.h"
#include "optimizer/optimizer.h"
#include "optimizer/pathnode.h"
#include "optimizer/paths.h"
#include "optimizer/placeholder.h"
#include "optimizer/plancat.h"
#include "optimizer/planmain.h"
#include "optimizer/prep.h"
#include "optimizer/restrictinfo.h"
#include "parser/parsetree.h"
#include "utils/array.h"
#include "utils/lsyscache.h"
#include "utils/ruleutils.h"
#include "utils/selfuncs.h"
#include "utils/spccache.h"
#include "utils/syscache.h"
#include "utils/tuplesort.h"

extern StringInfo sub_query;
extern void get_single_rel (PlannerInfo *root, RelOptInfo *rel); 
extern void get_parameterized_baserel (PlannerInfo *root, RelOptInfo *rel, List *param_clauses);
extern void get_join_rel (PlannerInfo *root, 
					RelOptInfo *join_rel,
					RelOptInfo *outer_rel,
					RelOptInfo *inner_rel,
					SpecialJoinInfo *sjinfo,
					List *restrictlist_in);
extern void get_parameterized_join_rel(PlannerInfo *root, 
					RelOptInfo *join_rel,
					Path *outer_path,
					Path *inner_path,
					SpecialJoinInfo *sjinfo,
					List *restrictlist_in);

#endif