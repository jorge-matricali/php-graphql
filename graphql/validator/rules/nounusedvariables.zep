namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Validator\ValidationContext;
class NoUnusedVariables extends AbstractValidationRule
{
    static function unusedVariableMessage(varName, opName = null)
    {
        return  opName ? "Variable \"\${varName}\" is never used in operation \"{opName}\"."  : "Variable \"\${varName}\" is never used.";
    }
    
    public variableDefs;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray3e65354d5e2b0cf7b84d59c10056dedd, variableNameUsed, usages, opName, usage, node, variableDef, variableName, tmpArraye337c7972c61e8ff701efcca16fc80c2;
    
        let this->variableDefs =  [];
        let this->variableDefs =  [];
        let variableNameUsed =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let opName =  operation->name ? operation->name->value  : null;
        let node = usage["node"];
        let variableNameUsed[node->name->value] = true;
        let variableName =  variableDef->variable->name->value;
        let this->variableDefs[] = def;
        let tmpArray3e65354d5e2b0cf7b84d59c10056dedd = let this->variableDefs =  [];
        let variableNameUsed =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let opName =  operation->name ? operation->name->value  : null;
        let node = usage["node"];
        let variableNameUsed[node->name->value] = true;
        let variableName =  variableDef->variable->name->value;
        let this->variableDefs[] = def;
        [NodeKind::OPERATION_DEFINITION : ["enter" : new NoUnusedVariablesgetVisitorClosureOne(), "leave" : new NoUnusedVariablesgetVisitorClosureOne(context)], NodeKind::VARIABLE_DEFINITION : new NoUnusedVariablesgetVisitorClosureOne()];
        return tmpArray0867e99022de8c882c226d9f88c2bd87;
    }

}