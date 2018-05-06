namespace GraphQL;

use GraphQL\Error\Error;
use GraphQL\Executor\ExecutionResult;
use GraphQL\Executor\Executor;
use GraphQL\Executor\Promise\Adapter\SyncPromiseAdapter;
use GraphQL\Executor\Promise\Promise;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\Parser;
use GraphQL\Language\Source;
use GraphQL\Executor\Promise\PromiseAdapter;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\Type;
use GraphQL\Validator\DocumentValidator;
use GraphQL\Validator\Rules\AbstractValidationRule;
use GraphQL\Validator\Rules\QueryComplexity;
/**
 * This is the primary facade for fulfilling GraphQL operations.
 * See [related documentation](executing-queries.md).
 */
class GraphQL
{
    /**
     * Executes graphql query.
     *
     * More sophisticated GraphQL servers, such as those which persist queries,
     * may wish to separate the validation and execution phases to a static time
     * tooling step, and a server runtime step.
     *
     * Available options:
     *
     * schema:
     *    The GraphQL type system to use when validating and executing a query.
     * source:
     *    A GraphQL language formatted string representing the requested operation.
     * rootValue:
     *    The value provided as the first argument to resolver functions on the top
     *    level type (e.g. the query object type).
     * context:
     *    The value provided as the third argument to all resolvers.
     *    Use this to pass current session, user data, etc
     * variableValues:
     *    A mapping of variable name to runtime value to use for all variables
     *    defined in the requestString.
     * operationName:
     *    The name of the operation to use if requestString contains multiple
     *    possible operations. Can be omitted if requestString contains only
     *    one operation.
     * fieldResolver:
     *    A resolver function to use when one is not provided by the schema.
     *    If not provided, the default field resolver is used (which looks for a
     *    value on the source value with the field's name).
     * validationRules:
     *    A set of rules for query validation step. Default value is all available rules.
     *    Empty array would allow to skip query validation (may be convenient for persisted
     *    queries which are validated before persisting and assumed valid during execution)
     *
     * @api
     * @param \GraphQL\Type\Schema $schema
     * @param string|DocumentNode $source
     * @param mixed $rootValue
     * @param mixed $context
     * @param array|null $variableValues
     * @param string|null $operationName
     * @param callable $fieldResolver
     * @param array $validationRules
     *
     * @return ExecutionResult
     */
    public static function executeQuery(<GraphQL\Type\Schema> schema, source, rootValue = null, context = null, variableValues = null, operationName = null, fieldResolver = null, array validationRules = null) -> <ExecutionResult>
    {
        var promiseAdapter, promise;
    
        let promiseAdapter =  new SyncPromiseAdapter();
        let promise =  self::promiseToExecute(promiseAdapter, schema, source, rootValue, context, variableValues, operationName, fieldResolver, validationRules);
        return promiseAdapter->wait(promise);
    }
    
    /**
     * Same as executeQuery(), but requires PromiseAdapter and always returns a Promise.
     * Useful for Async PHP platforms.
     *
     * @api
     * @param PromiseAdapter $promiseAdapter
     * @param \GraphQL\Type\Schema $schema
     * @param string|DocumentNode $source
     * @param mixed $rootValue
     * @param mixed $context
     * @param array|null $variableValues
     * @param string|null $operationName
     * @param callable $fieldResolver
     * @param array $validationRules
     *
     * @return Promise
     */
    public static function promiseToExecute(<PromiseAdapter> promiseAdapter, <GraphQL\Type\Schema> schema, source, rootValue = null, context = null, variableValues = null, operationName = null, fieldResolver = null, array validationRules = null) -> <Promise>
    {
        var documentNode, rule, queryComplexity, validationErrors, e, tmpArrayc79ded649cde17dd5cfd81207af70013;
    
        try {
            if source instanceof DocumentNode {
                let documentNode = source;
            } else {
                let documentNode =  Parser::parse(new Source( source ? source : "", "GraphQL"));
            }
            // FIXME
            if !(empty(validationRules)) {
                for rule in validationRules {
                    if rule instanceof QueryComplexity {
                        rule->setRawVariableValues(variableValues);
                    }
                }
            } else {
                /** @var QueryComplexity $queryComplexity */
                let queryComplexity =  DocumentValidator::getRule(QueryComplexity::class);
                queryComplexity->setRawVariableValues(variableValues);
            }
            let validationErrors =  DocumentValidator::validate(schema, documentNode, validationRules);
            if !(empty(validationErrors)) {
                return promiseAdapter->createFulfilled(new ExecutionResult(null, validationErrors));
            } else {
                return Executor::promiseToExecute(promiseAdapter, schema, documentNode, rootValue, context, variableValues, operationName, fieldResolver);
            }
        } catch Error, e {
            let tmpArrayc79ded649cde17dd5cfd81207af70013 = [e];
            return promiseAdapter->createFulfilled(new ExecutionResult(null, tmpArrayc79ded649cde17dd5cfd81207af70013));
        }
    }
    
    /**
     * @deprecated Use executeQuery()->toArray() instead
     *
     * @param \GraphQL\Type\Schema $schema
     * @param string|DocumentNode $source
     * @param mixed $rootValue
     * @param mixed $contextValue
     * @param array|null $variableValues
     * @param string|null $operationName
     * @return Promise|array
     */
    public static function execute(<GraphQL\Type\Schema> schema, source, rootValue = null, contextValue = null, variableValues = null, operationName = null)
    {
        var result, promiseAdapter;
    
        let result =  self::promiseToExecute(let promiseAdapter =  Executor::getPromiseAdapter(), schema, source, rootValue, contextValue, variableValues, operationName);
        if promiseAdapter instanceof SyncPromiseAdapter {
            let result =  promiseAdapter->wait(result)->toArray();
        } else {
            let result =  result->then(new GraphQLexecuteClosureOne());
        }
        return result;
    }
    
    /**
     * @deprecated renamed to executeQuery()
     *
     * @param \GraphQL\Type\Schema $schema
     * @param string|DocumentNode $source
     * @param mixed $rootValue
     * @param mixed $contextValue
     * @param array|null $variableValues
     * @param string|null $operationName
     *
     * @return ExecutionResult|Promise
     */
    public static function executeAndReturnResult(<GraphQL\Type\Schema> schema, source, rootValue = null, contextValue = null, variableValues = null, operationName = null)
    {
        var result, promiseAdapter;
    
        let result =  self::promiseToExecute(let promiseAdapter =  Executor::getPromiseAdapter(), schema, source, rootValue, contextValue, variableValues, operationName);
        if promiseAdapter instanceof SyncPromiseAdapter {
            let result =  promiseAdapter->wait(result);
        }
        return result;
    }
    
    /**
     * Returns directives defined in GraphQL spec
     *
     * @api
     * @return Directive[]
     */
    public static function getStandardDirectives() -> array
    {
        return array_values(Directive::getInternalDirectives());
    }
    
    /**
     * Returns types defined in GraphQL spec
     *
     * @api
     * @return Type[]
     */
    public static function getStandardTypes() -> array
    {
        return array_values(Type::getInternalTypes());
    }
    
    /**
     * Returns standard validation rules implementing GraphQL spec
     *
     * @api
     * @return AbstractValidationRule[]
     */
    public static function getStandardValidationRules() -> array
    {
        return array_values(DocumentValidator::defaultRules());
    }
    
    /**
     * @param callable $fn
     */
    public static function setDefaultFieldResolver(fn) -> void
    {
        Executor::setDefaultFieldResolver(fn);
    }
    
    /**
     * @param PromiseAdapter|null $promiseAdapter
     */
    public static function setPromiseAdapter(<PromiseAdapter> promiseAdapter = null) -> void
    {
        Executor::setPromiseAdapter(promiseAdapter);
    }
    
    /**
     * Returns directives defined in GraphQL spec
     *
     * @deprecated Renamed to getStandardDirectives
     * @return Directive[]
     */
    public static function getInternalDirectives() -> array
    {
        return self::getStandardDirectives();
    }

}