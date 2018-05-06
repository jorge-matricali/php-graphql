namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
/**
 * Known argument names
 *
 * A GraphQL field is only valid if all supplied arguments are defined by
 * that field.
 */
class KnownArgumentNames extends AbstractValidationRule
{
    public static function unknownArgMessage(argName, fieldName, typeName, array suggestedArgs)
    {
        var message;
    
        let message = "Unknown argument \"{argName}\" on field \"{fieldName}\" of type \"{typeName}\".";
        if suggestedArgs {
            let message .= " Did you mean " . Utils::quotedOrList(suggestedArgs) . "?";
        }
        return message;
    }
    
    public static function unknownDirectiveArgMessage(argName, directiveName, array suggestedArgs)
    {
        var message;
    
        let message = "Unknown argument \"{argName}\" on directive \"@{directiveName}\".";
        if suggestedArgs {
            let message .= " Did you mean " . Utils::quotedOrList(suggestedArgs) . "?";
        }
        return message;
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayaeeed8cd48f4a6c9739b6455cf74a7a3, argDef, argumentOf, fieldDef, parentType, tmpArrayf4fc5cf591e2da906172bb792f95ec53, directive, tmpArray0ac9bfde34a6d3381609663c5313496d;
    
        let argDef =  context->getArgument();
        let argumentOf = ancestors[count(ancestors) - 1];
        let fieldDef =  context->getFieldDef();
        let parentType =  context->getParentType();
        let directive =  context->getDirective();
        let tmpArrayaeeed8cd48f4a6c9739b6455cf74a7a3 = let argDef =  context->getArgument();
        let argumentOf = ancestors[count(ancestors) - 1];
        let fieldDef =  context->getFieldDef();
        let parentType =  context->getParentType();
        let directive =  context->getDirective();
        [NodeKind::ARGUMENT : new KnownArgumentNamesgetVisitorClosureOne(context)];
        return tmpArray37aef62b380e87cc8dcd7d042f411509;
    }

}