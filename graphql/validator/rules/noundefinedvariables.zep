namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Validator\ValidationContext;
/**
 * Class NoUndefinedVariables
 *
 * A GraphQL operation is only valid if all variables encountered, both directly
 * and via fragment spreads, are defined by that operation.
 *
 * @package GraphQL\Validator\Rules
 */
class NoUndefinedVariables extends AbstractValidationRule
{
    static function undefinedVarMessage(varName, opName = null)
    {
        return  opName ? "Variable \"\${varName}\" is not defined by operation \"{opName}\"."  : "Variable \"\${varName}\" is not defined.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var variableNameDefined, tmpArrayca2dc5515b18992188ed2a48e40362e9, usages, usage, node, varName, tmpArray7af6d14b26594c512968f9ba0219b69b;
    
        let variableNameDefined =  [];
        let variableNameDefined =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let node = usage["node"];
        let varName =  node->name->value;
        let variableNameDefined[def->variable->name->value] = true;
        let tmpArrayca2dc5515b18992188ed2a48e40362e9 = let variableNameDefined =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let node = usage["node"];
        let varName =  node->name->value;
        let variableNameDefined[def->variable->name->value] = true;
        [NodeKind::OPERATION_DEFINITION : ["enter" : new NoUndefinedVariablesgetVisitorClosureOne(variableNameDefined), "leave" : new NoUndefinedVariablesgetVisitorClosureOne(variableNameDefined, context)], NodeKind::VARIABLE_DEFINITION : new NoUndefinedVariablesgetVisitorClosureOne(variableNameDefined)];
        return tmpArray60677fb52d6b5aa54a48eeea022c2e39;
    }

}