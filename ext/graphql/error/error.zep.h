
extern zend_class_entry *graphql_error_error_ce;

ZEPHIR_INIT_CLASS(GraphQL_Error_Error);

PHP_METHOD(GraphQL_Error_Error, version);

ZEPHIR_INIT_FUNCS(graphql_error_error_method_entry) {
	PHP_ME(GraphQL_Error_Error, version, NULL, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_FE_END
};
