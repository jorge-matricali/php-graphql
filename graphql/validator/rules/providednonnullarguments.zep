namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DirectiveNode;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
class ProvidedNonNullArguments extends AbstractValidationRule
{
    static function missingFieldArgMessage(fieldName, argName, type)
    {
        return "Field \"{fieldName}\" argument \"{argName}\" of type \"{type}\" is required but not provided.";
    }
    
    static function missingDirectiveArgMessage(directiveName, argName, type)
    {
        return "Directive \"@{directiveName}\" argument \"{argName}\" of type \"{type}\" is required but not provided.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray2e0159e79b09c662ccef0d8442b6721c, fieldDef, argNodes, argNodeMap, argNode, argDef, tmpArray22954c7a1e398de97d86918d598a7e74, directiveDef, tmpArraye283f814ff7c014a2030d8467fc67675;
    
        let fieldDef =  context->getFieldDef();
        let argNodes =  fieldNode->arguments ? fieldNode->arguments : [];
        let argNodeMap =  [];
        let argNodeMap[argNode->name->value] = argNodes;
        let argNode =  isset argNodeMap[argDef->name] ? argNodeMap[argDef->name]  : null;
        let directiveDef =  context->getDirective();
        let argNodes =  directiveNode->arguments ? directiveNode->arguments : [];
        let argNodeMap =  [];
        let argNodeMap[argNode->name->value] = argNodes;
        let argNode =  isset argNodeMap[argDef->name] ? argNodeMap[argDef->name]  : null;
        let tmpArray2e0159e79b09c662ccef0d8442b6721c = let fieldDef =  context->getFieldDef();
        let argNodes =  fieldNode->arguments ? fieldNode->arguments : [];
        let argNodeMap =  [];
        let argNodeMap[argNode->name->value] = argNodes;
        let argNode =  isset argNodeMap[argDef->name] ? argNodeMap[argDef->name]  : null;
        let directiveDef =  context->getDirective();
        let argNodes =  directiveNode->arguments ? directiveNode->arguments : [];
        let argNodeMap =  [];
        let argNodeMap[argNode->name->value] = argNodes;
        let argNode =  isset argNodeMap[argDef->name] ? argNodeMap[argDef->name]  : null;
        [NodeKind::FIELD : ["leave" : new ProvidedNonNullArgumentsgetVisitorClosureOne(context)], NodeKind::DIRECTIVE : ["leave" : new ProvidedNonNullArgumentsgetVisitorClosureOne(context)]];
        return tmpArray53372e0dd94886814ab7d2483c472474;
    }

}