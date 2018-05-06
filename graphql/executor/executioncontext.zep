namespace GraphQL\Executor;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Type\Schema;
/**
 * Data that must be available at all points during query execution.
 *
 * Namely, schema of the type system that is currently executing,
 * and the fragments defined in the query document
 *
 * @internal
 */
class ExecutionContext
{
    /**
     * @var Schema
     */
    public schema;
    /**
     * @var FragmentDefinitionNode[]
     */
    public fragments;
    /**
     * @var mixed
     */
    public rootValue;
    /**
     * @var mixed
     */
    public contextValue;
    /**
     * @var OperationDefinitionNode
     */
    public operation;
    /**
     * @var array
     */
    public variableValues;
    /**
     * @var callable
     */
    public fieldResolver;
    /**
     * @var array
     */
    public errors;
    public function __construct(schema, fragments, root, contextValue, operation, variables, errors, fieldResolver, promiseAdapter) -> void
    {
        let this->schema = schema;
        let this->fragments = fragments;
        let this->rootValue = root;
        let this->contextValue = contextValue;
        let this->operation = operation;
        let this->variableValues = variables;
        let this->errors =  errors ? errors : [];
        let this->fieldResolver = fieldResolver;
        let this->promises = promiseAdapter;
    }
    
    public function addError(<Error> error)
    {
        let this->errors[] = error;
        return this;
    }

}