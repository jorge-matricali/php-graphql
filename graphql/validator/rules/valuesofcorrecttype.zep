namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\BooleanValueNode;
use GraphQL\Language\AST\EnumValueNode;
use GraphQL\Language\AST\FloatValueNode;
use GraphQL\Language\AST\IntValueNode;
use GraphQL\Language\AST\ListValueNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NullValueNode;
use GraphQL\Language\AST\ObjectFieldNode;
use GraphQL\Language\AST\ObjectValueNode;
use GraphQL\Language\AST\StringValueNode;
use GraphQL\Language\AST\ValueNode;
use GraphQL\Language\Printer;
use GraphQL\Language\Visitor;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\EnumValueDefinition;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
/**
 * Value literals of correct type
 *
 * A GraphQL document is only valid if all value literals are of the type
 * expected at their position.
 */
class ValuesOfCorrectType extends AbstractValidationRule
{
    static function badValueMessage(typeName, valueName, message = null)
    {
        return "Expected type {typeName}, found {valueName}" . ( message ? "; {message}"  : ".");
    }
    
    static function requiredFieldMessage(typeName, fieldName, fieldTypeName)
    {
        return "Field {typeName}.{fieldName} of required type " . "{fieldTypeName} was not provided.";
    }
    
    static function unknownFieldMessage(typeName, fieldName, message = null)
    {
        return "Field \"{fieldName}\" is not defined by type {typeName}" . ( message ? "; {message}"  : ".");
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray3d55af93c010a448173f719820fb0bfb, type, inputFields, nodeFields, fieldNodeMap, fieldName, fieldDef, fieldType, parentType, suggestions, didYouMean;
    
        let type =  context->getInputType();
        let type =  Type::getNullableType(context->getParentInputType());
        let type =  Type::getNamedType(context->getInputType());
        let inputFields =  type->getFields();
        let nodeFields =  iterator_to_array(node->fields);
        let fieldNodeMap =  array_combine(array_map(new ValuesOfCorrectTypegetVisitorClosureOne(), nodeFields), array_values(nodeFields));
        let fieldType =  fieldDef->getType();
        let parentType =  Type::getNamedType(context->getParentInputType());
        let fieldType =  context->getInputType();
        let suggestions =  Utils::suggestionList(node->name->value, array_keys(parentType->getFields()));
        let didYouMean =  suggestions ? "Did you mean " . Utils::orList(suggestions) . "?"  : null;
        let type =  Type::getNamedType(context->getInputType());
        let tmpArray3d55af93c010a448173f719820fb0bfb = let type =  context->getInputType();
        let type =  Type::getNullableType(context->getParentInputType());
        let type =  Type::getNamedType(context->getInputType());
        let inputFields =  type->getFields();
        let nodeFields =  iterator_to_array(node->fields);
        let fieldNodeMap =  array_combine(array_map(new ValuesOfCorrectTypegetVisitorClosureOne(), nodeFields), array_values(nodeFields));
        let fieldType =  fieldDef->getType();
        let parentType =  Type::getNamedType(context->getParentInputType());
        let fieldType =  context->getInputType();
        let suggestions =  Utils::suggestionList(node->name->value, array_keys(parentType->getFields()));
        let didYouMean =  suggestions ? "Did you mean " . Utils::orList(suggestions) . "?"  : null;
        let type =  Type::getNamedType(context->getInputType());
        [NodeKind::NULL : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::LST : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::OBJECT : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::OBJECT_FIELD : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::ENUM : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::INT : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::FLOAT : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::STRING : new ValuesOfCorrectTypegetVisitorClosureOne(context), NodeKind::BOOLEAN : new ValuesOfCorrectTypegetVisitorClosureOne(context)];
        return tmpArray9a3fd7d43eae9f5f0961e32465ab3928;
    }
    
    protected function isValidScalar(<ValidationContext> context, <ValueNode> node)
    {
        var locationType, type, parseResult, error;
    
        // Report any error at the full type expected by the location.
        let locationType =  context->getInputType();
        if !(locationType) {
            return;
        }
        let type =  Type::getNamedType(locationType);
        if !(type instanceof ScalarType) {
            context->reportError(new Error(self::badValueMessage((string) locationType, Printer::doPrint(node), this->enumTypeSuggestion(type, node)), node));
            return;
        }
        // Scalars determine if a literal value is valid via parseLiteral() which
        // may throw or return an invalid value to indicate failure.
        try {
            let parseResult =  type->parseLiteral(node);
            if Utils::isInvalid(parseResult) {
                context->reportError(new Error(self::badValueMessage((string) locationType, Printer::doPrint(node)), node));
            }
        } catch \Exception, error {
            // Ensure a reference to the original error is maintained.
            context->reportError(new Error(self::badValueMessage((string) locationType, Printer::doPrint(node), error->getMessage()), node, null, null, null, error));
        } catch \Throwable, error {
            // Ensure a reference to the original error is maintained.
            context->reportError(new Error(self::badValueMessage((string) locationType, Printer::doPrint(node), error->getMessage()), node, null, null, null, error));
        }
    }
    
    protected function enumTypeSuggestion(type, <ValueNode> node)
    {
        var suggestions;
    
        if type instanceof EnumType {
            let suggestions =  Utils::suggestionList(Printer::doPrint(node), array_map(new ValuesOfCorrectTypeenumTypeSuggestionClosureOne(), type->getValues()));
            return  suggestions ? "Did you mean the enum value " . Utils::orList(suggestions) . "?"  : null;
        }
    }

}