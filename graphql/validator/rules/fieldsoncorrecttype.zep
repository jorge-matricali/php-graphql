namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Schema;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
class FieldsOnCorrectType extends AbstractValidationRule
{
    static function undefinedFieldMessage(fieldName, type, array suggestedTypeNames, array suggestedFieldNames)
    {
        var message, suggestions;
    
        let message =  "Cannot query field \"" . fieldName . "\" on type \"" . type . "\".";
        if suggestedTypeNames {
            let suggestions =  Utils::quotedOrList(suggestedTypeNames);
            let message .= " Did you mean to use an inline fragment on {suggestions}?";
        } else {
            if suggestedFieldNames {
                let suggestions =  Utils::quotedOrList(suggestedFieldNames);
                let message .= " Did you mean {suggestions}?";
            }
        }
        return message;
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayeaa3e3cb538dae39e87eb7326c8ec8d3, type, fieldDef, schema, fieldName, suggestedTypeNames, suggestedFieldNames, tmpArray1ee95516301de457c03238e62de0f9de;
    
        let type =  context->getParentType();
        let fieldDef =  context->getFieldDef();
        let schema =  context->getSchema();
        let fieldName =  node->name->value;
        let suggestedTypeNames =  this->getSuggestedTypeNames(schema, type, fieldName);
        let suggestedFieldNames =  suggestedTypeNames ? []  : this->getSuggestedFieldNames(schema, type, fieldName);
        let tmpArrayeaa3e3cb538dae39e87eb7326c8ec8d3 = let type =  context->getParentType();
        let fieldDef =  context->getFieldDef();
        let schema =  context->getSchema();
        let fieldName =  node->name->value;
        let suggestedTypeNames =  this->getSuggestedTypeNames(schema, type, fieldName);
        let suggestedFieldNames =  suggestedTypeNames ? []  : this->getSuggestedFieldNames(schema, type, fieldName);
        [NodeKind::FIELD : new FieldsOnCorrectTypegetVisitorClosureOne(context)];
        return tmpArray86300593d8a94ab1521799a24bd959ea;
    }
    
    /**
     * Go through all of the implementations of type, as well as the interfaces
     * that they implement. If any of those types include the provided field,
     * suggest them, sorted by how often the type is referenced, starting
     * with Interfaces.
     *
     * @param Schema $schema
     * @param $type
     * @param string $fieldName
     * @return array
     */
    protected function getSuggestedTypeNames(<Schema> schema, type, string fieldName) -> array
    {
        var suggestedObjectTypes, interfaceUsageCount, possibleType, fields, possibleInterface, suggestedInterfaceTypes, tmpArray40cd750bba9870f18aada2478b24840a;
    
        if Type::isAbstractType(type) {
            let suggestedObjectTypes =  [];
            let interfaceUsageCount =  [];
            for possibleType in schema->getPossibleTypes(type) {
                let fields =  possibleType->getFields();
                if !(isset fields[fieldName]) {
                    continue;
                }
                // This object type defines this field.
                let suggestedObjectTypes[] = possibleType->name;
                for possibleInterface in possibleType->getInterfaces() {
                    let fields =  possibleInterface->getFields();
                    if !(isset fields[fieldName]) {
                        continue;
                    }
                    // This interface type defines this field.
                    let interfaceUsageCount[possibleInterface->name] =  !(isset interfaceUsageCount[possibleInterface->name]) ? 0  : interfaceUsageCount[possibleInterface->name] + 1;
                }
            }
            // Suggest interface types based on how common they are.
            arsort(interfaceUsageCount);
            let suggestedInterfaceTypes =  array_keys(interfaceUsageCount);
            // Suggest both interface and object types.
            return array_merge(suggestedInterfaceTypes, suggestedObjectTypes);
        }
        // Otherwise, must be an Object type, which does not have possible fields.
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return tmpArray40cd750bba9870f18aada2478b24840a;
    }
    
    /**
     * For the field name provided, determine if there are any similar field names
     * that may be the result of a typo.
     *
     * @param Schema $schema
     * @param $type
     * @param string $fieldName
     * @return array|string[]
     */
    protected function getSuggestedFieldNames(<Schema> schema, type, string fieldName)
    {
        var possibleFieldNames, tmpArray40cd750bba9870f18aada2478b24840a;
    
        if type instanceof ObjectType || type instanceof InterfaceType {
            let possibleFieldNames =  array_keys(type->getFields());
            return Utils::suggestionList(fieldName, possibleFieldNames);
        }
        // Otherwise, must be a Union type, which does not define fields.
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return tmpArray40cd750bba9870f18aada2478b24840a;
    }

}