
/* This file was generated automatically by Zephir do not modify it! */

#ifndef PHP_GRAPHQL_H
#define PHP_GRAPHQL_H 1

#ifdef PHP_WIN32
#define ZEPHIR_RELEASE 1
#endif

#include "kernel/globals.h"

#define PHP_GRAPHQL_NAME        "graphql"
#define PHP_GRAPHQL_VERSION     "0.0.1"
#define PHP_GRAPHQL_EXTNAME     "graphql"
#define PHP_GRAPHQL_AUTHOR      ""
#define PHP_GRAPHQL_ZEPVERSION  "0.10.9-a9589700c9"
#define PHP_GRAPHQL_DESCRIPTION ""



ZEND_BEGIN_MODULE_GLOBALS(graphql)

	int initialized;

	/* Memory */
	zephir_memory_entry *start_memory; /**< The first preallocated frame */
	zephir_memory_entry *end_memory; /**< The last preallocate frame */
	zephir_memory_entry *active_memory; /**< The current memory frame */

	/* Virtual Symbol Tables */
	zephir_symbol_table *active_symbol_table;

	/** Function cache */
	HashTable *fcache;

	zephir_fcall_cache_entry *scache[ZEPHIR_MAX_CACHE_SLOTS];

	/* Cache enabled */
	unsigned int cache_enabled;

	/* Max recursion control */
	unsigned int recursive_lock;

	/* Global constants */
	zval *global_true;
	zval *global_false;
	zval *global_null;
	
ZEND_END_MODULE_GLOBALS(graphql)

#ifdef ZTS
#include "TSRM.h"
#endif

ZEND_EXTERN_MODULE_GLOBALS(graphql)

#ifdef ZTS
	#define ZEPHIR_GLOBAL(v) TSRMG(graphql_globals_id, zend_graphql_globals *, v)
#else
	#define ZEPHIR_GLOBAL(v) (graphql_globals.v)
#endif

#ifdef ZTS
	#define ZEPHIR_VGLOBAL ((zend_graphql_globals *) (*((void ***) tsrm_ls))[TSRM_UNSHUFFLE_RSRC_ID(graphql_globals_id)])
#else
	#define ZEPHIR_VGLOBAL &(graphql_globals)
#endif

#define ZEPHIR_API ZEND_API

#define zephir_globals_def graphql_globals
#define zend_zephir_globals_def zend_graphql_globals

extern zend_module_entry graphql_module_entry;
#define phpext_graphql_ptr &graphql_module_entry

#endif
