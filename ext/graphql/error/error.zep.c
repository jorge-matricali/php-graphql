
#ifdef HAVE_CONFIG_H
#include "../../ext_config.h"
#endif

#include <php.h>
#include "../../php_ext.h"
#include "../../ext.h"

#include <Zend/zend_operators.h>
#include <Zend/zend_exceptions.h>
#include <Zend/zend_interfaces.h>

#include "kernel/main.h"


ZEPHIR_INIT_CLASS(GraphQL_Error_Error) {

	ZEPHIR_REGISTER_CLASS(GraphQL\\Error, Error, graphql, error_error, graphql_error_error_method_entry, 0);

	return SUCCESS;

}

PHP_METHOD(GraphQL_Error_Error, version) {

	zval *this_ptr = getThis();


	RETURN_STRING("1.0");

}

