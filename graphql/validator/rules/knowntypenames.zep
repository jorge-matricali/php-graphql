namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
/**
 * Known type names
 *
 * A GraphQL document is only valid if referenced types (specifically
 * variable definitions and fragment conditions) are defined by the type schema.
 */
class KnownTypeNames extends AbstractValidationRule
{
    static function unknownTypeMessage(type, array suggestedTypes)
    {
        var message, suggestions;
    
        let message = "Unknown type \"{type}\".";
        if suggestedTypes {
            let suggestions =  Utils::quotedOrList(suggestedTypes);
            let message .= " Did you mean {suggestions}?";
        }
        return message;
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var skip, tmpArray97b847e21c3ca6c143da5802d09978a8, schema, typeName, type, tmpArray373ea674073d223daaf55bf0b32c885b;
    
        let skip =  new KnownTypeNamesgetVisitorClosureOne();
        let schema =  context->getSchema();
        let typeName =  node->name->value;
        let type =  schema->getType(typeName);
        let tmpArray97b847e21c3ca6c143da5802d09978a8 = let schema =  context->getSchema();
        let typeName =  node->name->value;
        let type =  schema->getType(typeName);
        [NodeKind::OBJECT_TYPE_DEFINITION : skip, NodeKind::INTERFACE_TYPE_DEFINITION : skip, NodeKind::UNION_TYPE_DEFINITION : skip, NodeKind::INPUT_OBJECT_TYPE_DEFINITION : skip, NodeKind::NAMED_TYPE : new KnownTypeNamesgetVisitorClosureOne(context)];
        return tmpArrayedc85242a85e8f5c69acfbe20a926faf;
    }

}