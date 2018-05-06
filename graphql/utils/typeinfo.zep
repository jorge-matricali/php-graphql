namespace GraphQL\Utils;

use GraphQL\Error\InvariantViolation;
use GraphQL\Error\Warning;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\ListTypeNode;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NonNullTypeNode;
use GraphQL\Type\Schema;
use GraphQL\Type\Definition\CompositeType;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\FieldArgument;
use GraphQL\Type\Definition\FieldDefinition;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InputType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Definition\WrappingType;
use GraphQL\Type\Introspection;
/**
 * Class TypeInfo
 * @package GraphQL\Utils
 */
class TypeInfo
{
    /**
     * @deprecated moved to GraphQL\Utils\TypeComparators
     */
    public static function isEqualType(<Type> typeA, <Type> typeB)
    {
        return TypeComparators::isEqualType(typeA, typeB);
    }
    
    /**
     * @deprecated moved to GraphQL\Utils\TypeComparators
     */
    static function isTypeSubTypeOf(<Schema> schema, <Type> maybeSubType, <Type> superType)
    {
        return TypeComparators::isTypeSubTypeOf(schema, maybeSubType, superType);
    }
    
    /**
     * @deprecated moved to GraphQL\Utils\TypeComparators
     */
    static function doTypesOverlap(<Schema> schema, <CompositeType> typeA, <CompositeType> typeB)
    {
        return TypeComparators::doTypesOverlap(schema, typeA, typeB);
    }
    
    /**
     * @param Schema $schema
     * @param NamedTypeNode|ListTypeNode|NonNullTypeNode $inputTypeNode
     * @return Type
     * @throws InvariantViolation
     */
    public static function typeFromAST(<Schema> schema, inputTypeNode) -> <Type>
    {
        return ast::typeFromAST(schema, inputTypeNode);
    }
    
    /**
     * Given root type scans through all fields to find nested types. Returns array where keys are for type name
     * and value contains corresponding type instance.
     *
     * Example output:
     * [
     *     'String' => $instanceOfStringType,
     *     'MyType' => $instanceOfMyType,
     *     ...
     * ]
     *
     * @param Type $type
     * @param array|null $typeMap
     * @return array
     */
    public static function extractTypes(<Type> type, array typeMap = null) -> array
    {
        var nestedTypes, fieldName, field, fieldArgTypes;
    
        if !(typeMap) {
            let typeMap =  [];
        }
        if !(type) {
            return typeMap;
        }
        if type instanceof WrappingType {
            return self::extractTypes(type->getWrappedType(true), typeMap);
        }
        if !(type instanceof Type) {
            Warning::warnOnce("One of the schema types is not a valid type definition instance. " . "Try running $schema->assertValid() to find out the cause of this warning.", Warning::WARNING_NOT_A_TYPE);
            return typeMap;
        }
        if !(empty(typeMap[type->name])) {
            Utils::invariant(typeMap[type->name] === type, "Schema must contain unique named types but contains multiple types named \"{type}\" " . "(see http://webonyx.github.io/graphql-php/type-system/#type-registry).");
            return typeMap;
        }
        let typeMap[type->name] = type;
        let nestedTypes =  [];
        if type instanceof UnionType {
            let nestedTypes =  type->getTypes();
        }
        if type instanceof ObjectType {
            let nestedTypes =  array_merge(nestedTypes, type->getInterfaces());
        }
        if type instanceof ObjectType || type instanceof InterfaceType {
            for fieldName, field in (array) type->getFields() {
                if !(empty(field->args)) {
                    let fieldArgTypes =  array_map(new TypeInfoextractTypesClosureOne(), field->args);
                    let nestedTypes =  array_merge(nestedTypes, fieldArgTypes);
                }
                let nestedTypes[] =  field->getType();
            }
        }
        if type instanceof InputObjectType {
            for fieldName, field in (array) type->getFields() {
                let nestedTypes[] =  field->getType();
            }
        }
        for type in nestedTypes {
            let typeMap =  self::extractTypes(type, typeMap);
        }
        return typeMap;
    }
    
    /**
     * Not exactly the same as the executor's definition of getFieldDef, in this
     * statically evaluated environment we do not always have an Object type,
     * and need to handle Interface and Union types.
     *
     * @return FieldDefinition
     */
    protected static function getFieldDefinition(<Schema> schema, <Type> parentType, <FieldNode> fieldNode) -> <FieldDefinition>
    {
        var name, schemaMeta, typeMeta, typeNameMeta, fields;
    
        let name =  fieldNode->name->value;
        let schemaMeta =  Introspection::schemaMetaFieldDef();
        if name === schemaMeta->name && schema->getQueryType() === parentType {
            return schemaMeta;
        }
        let typeMeta =  Introspection::typeMetaFieldDef();
        if name === typeMeta->name && schema->getQueryType() === parentType {
            return typeMeta;
        }
        let typeNameMeta =  Introspection::typeNameMetaFieldDef();
        if name === typeNameMeta->name && parentType instanceof CompositeType {
            return typeNameMeta;
        }
        if parentType instanceof ObjectType || parentType instanceof InterfaceType {
            let fields =  parentType->getFields();
            return  isset fields[name] ? fields[name]  : null;
        }
        return null;
    }
    
    /**
     * @var Schema
     */
    protected schema;
    /**
     * @var \SplStack<OutputType>
     */
    protected typeStack;
    /**
     * @var \SplStack<CompositeType>
     */
    protected parentTypeStack;
    /**
     * @var \SplStack<InputType>
     */
    protected inputTypeStack;
    /**
     * @var \SplStack<FieldDefinition>
     */
    protected fieldDefStack;
    /**
     * @var Directive
     */
    protected directive;
    /**
     * @var FieldArgument
     */
    protected argument;
    /**
     * @var mixed
     */
    protected enumValue;
    /**
     * TypeInfo constructor.
     * @param Schema $schema
     * @param Type|null $initialType
     */
    public function __construct(<Schema> schema, initialType = null) -> void
    {
        let this->schema = schema;
        let this->typeStack =  [];
        let this->parentTypeStack =  [];
        let this->inputTypeStack =  [];
        let this->fieldDefStack =  [];
        if initialType {
            if Type::isInputType(initialType) {
                let this->inputTypeStack[] = initialType;
            }
            if Type::isCompositeType(initialType) {
                let this->parentTypeStack[] = initialType;
            }
            if Type::isOutputType(initialType) {
                let this->typeStack[] = initialType;
            }
        }
    }
    
    /**
     * @return Type
     */
    function getType() -> <Type>
    {
        if !(empty(this->typeStack)) {
            return this->typeStack[count(this->typeStack) - 1];
        }
        return null;
    }
    
    /**
     * @return CompositeType
     */
    function getParentType() -> <CompositeType>
    {
        if !(empty(this->parentTypeStack)) {
            return this->parentTypeStack[count(this->parentTypeStack) - 1];
        }
        return null;
    }
    
    /**
     * @return InputType
     */
    function getInputType() -> <InputType>
    {
        if !(empty(this->inputTypeStack)) {
            return this->inputTypeStack[count(this->inputTypeStack) - 1];
        }
        return null;
    }
    
    /**
     * @return InputType|null
     */
    public function getParentInputType()
    {
        var inputTypeStackLength;
    
        let inputTypeStackLength =  count(this->inputTypeStack);
        if inputTypeStackLength > 1 {
            return this->inputTypeStack[inputTypeStackLength - 2];
        }
    }
    
    /**
     * @return FieldDefinition
     */
    function getFieldDef() -> <FieldDefinition>
    {
        if !(empty(this->fieldDefStack)) {
            return this->fieldDefStack[count(this->fieldDefStack) - 1];
        }
        return null;
    }
    
    /**
     * @return Directive|null
     */
    function getDirective()
    {
        return this->directive;
    }
    
    /**
     * @return FieldArgument|null
     */
    function getArgument()
    {
        return this->argument;
    }
    
    /**
     * @return mixed
     */
    function getEnumValue()
    {
        return this->enumValue;
    }
    
    /**
     * @param Node $node
     */
    function enter(<Node> node)
    {
        var schema, namedType, parentType, fieldDef, fieldType, type, typeConditionNode, outputType, inputType, fieldOrDirective, argDef, argType, listType, itemType, objectType, inputFieldType, tmp, inputField, enumType, enumValue;
    
        let schema =  this->schema;
        // Note: many of the types below are explicitly typed as "mixed" to drop
        // any assumptions of a valid schema to ensure runtime types are properly
        // checked before continuing since TypeInfo is used as part of validation
        // which occurs before guarantees of schema and document validity.
        if NodeKind::SELECTION_SET {
            let namedType =  Type::getNamedType(this->getType());
            let this->parentTypeStack[] =  Type::isCompositeType(namedType) ? namedType  : null;
        } elseif NodeKind::OBJECT_FIELD {
            let objectType =  Type::getNamedType(this->getInputType());
            let fieldType =  null;
            let inputFieldType =  null;
            if objectType instanceof InputObjectType {
                let tmp =  objectType->getFields();
                let inputField =  isset tmp[node->name->value] ? tmp[node->name->value]  : null;
                let inputFieldType =  inputField ? inputField->getType()  : null;
            }
            let this->inputTypeStack[] =  Type::isInputType(inputFieldType) ? inputFieldType  : null;
        } elseif NodeKind::LST {
            let listType =  Type::getNullableType(this->getInputType());
            let itemType =  listType instanceof ListOfType ? listType->getWrappedType()  : listType;
            let this->inputTypeStack[] =  Type::isInputType(itemType) ? itemType  : null;
        } elseif NodeKind::ARGUMENT {
            let fieldOrDirective =  this->getDirective() ? this->getDirective() : this->getFieldDef();
            let argDef = null;
            let argType = null;
            ;
            if fieldOrDirective {
                let argDef =  Utils::find(fieldOrDirective->args, new TypeInfoenterClosureOne(node));
                if argDef {
                    let argType =  argDef->getType();
                }
            }
            let this->argument = argDef;
            let this->inputTypeStack[] =  Type::isInputType(argType) ? argType  : null;
        } elseif NodeKind::VARIABLE_DEFINITION {
            let inputType =  self::typeFromAST(schema, node->type);
            let this->inputTypeStack[] =  Type::isInputType(inputType) ? inputType  : null;
        } elseif NodeKind::INLINE_FRAGMENT || NodeKind::FRAGMENT_DEFINITION {
            let typeConditionNode =  node->typeCondition;
            let outputType =  typeConditionNode ? self::typeFromAST(schema, typeConditionNode)  : Type::getNamedType(this->getType());
            let this->typeStack[] =  Type::isOutputType(outputType) ? outputType  : null;
        } elseif NodeKind::OPERATION_DEFINITION {
            let type =  null;
            if node->operation === "query" {
                let type =  schema->getQueryType();
            } else {
                if node->operation === "mutation" {
                    let type =  schema->getMutationType();
                } else {
                    if node->operation === "subscription" {
                        let type =  schema->getSubscriptionType();
                    }
                }
            }
            let this->typeStack[] =  Type::isOutputType(type) ? type  : null;
        } elseif NodeKind::DIRECTIVE {
            let this->directive =  schema->getDirective(node->name->value);
        } elseif NodeKind::FIELD {
            let parentType =  this->getParentType();
            let fieldDef =  null;
            if parentType {
                let fieldDef =  self::getFieldDefinition(schema, parentType, node);
            }
            let fieldType =  null;
            if fieldDef {
                let fieldType =  fieldDef->getType();
            }
            let this->fieldDefStack[] = fieldDef;
            let this->typeStack[] =  Type::isOutputType(fieldType) ? fieldType  : null;
        } else {
            let enumType =  Type::getNamedType(this->getInputType());
            let enumValue =  null;
            if enumType instanceof EnumType {
                let enumValue =  enumType->getValue(node->value);
            }
            let this->enumValue = enumValue;
        }
    }
    
    /**
     * @param Node $node
     */
    function leave(<Node> node) -> void
    {
        if NodeKind::SELECTION_SET {
            array_pop(this->parentTypeStack);
        } elseif NodeKind::LST || NodeKind::OBJECT_FIELD {
            array_pop(this->inputTypeStack);
        } elseif NodeKind::ARGUMENT {
            let this->argument =  null;
            array_pop(this->inputTypeStack);
        } elseif NodeKind::VARIABLE_DEFINITION {
            array_pop(this->inputTypeStack);
        } elseif NodeKind::OPERATION_DEFINITION || NodeKind::INLINE_FRAGMENT || NodeKind::FRAGMENT_DEFINITION {
            array_pop(this->typeStack);
        } elseif NodeKind::DIRECTIVE {
            let this->directive =  null;
        } elseif NodeKind::FIELD {
            array_pop(this->fieldDefStack);
            array_pop(this->typeStack);
        } else {
            let this->enumValue =  null;
        }
    }

}