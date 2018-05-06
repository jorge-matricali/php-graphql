
extern zend_class_entry *graphql_graphql_ce;

ZEPHIR_INIT_CLASS(GraphQL_GraphQL);

PHP_METHOD(GraphQL_GraphQL, version);

ZEPHIR_INIT_FUNCS(graphql_graphql_method_entry) {
	PHP_ME(GraphQL_GraphQL, version, NULL, ZEND_ACC_PUBLIC|ZEND_ACC_STATIC)
	PHP_FE_END
};
