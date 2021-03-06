
#ifdef HAVE_CONFIG_H
#include "../ext_config.h"
#endif

#include <php.h>
#include "../php_ext.h"
#include "../ext.h"

#include <Zend/zend_operators.h>
#include <Zend/zend_exceptions.h>
#include <Zend/zend_interfaces.h>

#include "kernel/main.h"


ZEPHIR_INIT_CLASS(GraphQL_GraphQL) {

	ZEPHIR_REGISTER_CLASS(GraphQL, GraphQL, graphql, graphql, graphql_graphql_method_entry, 0);

	return SUCCESS;

}

PHP_METHOD(GraphQL_GraphQL, version) {

	zval *this_ptr = getThis();


	RETURN_STRING("1.0");

}

