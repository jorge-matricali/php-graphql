namespace GraphQL\Utils;

use GraphQL\Error\Error;
use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\BooleanValueNode;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\EnumValueNode;
use GraphQL\Language\AST\FloatValueNode;
use GraphQL\Language\AST\IntValueNode;
use GraphQL\Language\AST\ListTypeNode;
use GraphQL\Language\AST\ListValueNode;
use GraphQL\Language\AST\Location;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\NameNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NodeList;
use GraphQL\Language\AST\NonNullTypeNode;
use GraphQL\Language\AST\NullValueNode;
use GraphQL\Language\AST\ObjectFieldNode;
use GraphQL\Language\AST\ObjectValueNode;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\StringValueNode;
use GraphQL\Language\AST\ValueNode;
use GraphQL\Language\AST\VariableNode;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\IDType;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InputType;
use GraphQL\Type\Definition\LeafType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Schema;
/**
 * Various utilities dealing with AST
 */
class ast
{
    /**
     * Convert representation of AST as an associative array to instance of GraphQL\Language\AST\Node.
     *
     * For example:
     *
     * ```php
     * AST::fromArray([
     *     'kind' => 'ListValue',
     *     'values' => [
     *         ['kind' => 'StringValue', 'value' => 'my str'],
     *         ['kind' => 'StringValue', 'value' => 'my other str']
     *     ],
     *     'loc' => ['start' => 21, 'end' => 25]
     * ]);
     * ```
     *
     * Will produce instance of `ListValueNode` where `values` prop is a lazily-evaluated `NodeList`
     * returning instances of `StringValueNode` on access.
     *
     * This is a reverse operation for AST::toArray($node)
     *
     * @api
     * @param array $node
     * @return Node
     */
    public static function fromArray(array node) -> <Node>
    {
        var kind, classs, instance, tmpArray40cd750bba9870f18aada2478b24840a, key, value;
    
        if !(isset node["kind"]) || !(isset NodeKind::classMap[node["kind"]]) {
            throw new InvariantViolation("Unexpected node structure: " . Utils::printSafeJson(node));
        }
        let kind =  isset node["kind"] ? node["kind"]  : null;
        let classs = NodeKind::classMap[kind];
        let instance =  new {classs}([]);
        if isset node["loc"], node["loc"]["start"], node["loc"]["end"] {
            let instance->loc =  Location::create(node["loc"]["start"], node["loc"]["end"]);
        }
        for key, value in node {
            if key === "loc" || key === "kind" {
                continue;
            }
            if is_array(value) {
                if isset value[0] || empty(value) {
                    let value =  new NodeList(value);
                } else {
                    let value =  self::fromArray(value);
                }
            }
            let instance->{key} = value;
        }
        return instance;
    }
    
    /**
     * Convert AST node to serializable array
     *
     * @api
     * @param Node $node
     * @return array
     */
    public static function toArray(<Node> node) -> array
    {
        return node->toArray(true);
    }
    
    /**
     * Produces a GraphQL Value AST given a PHP value.
     *
     * Optionally, a GraphQL type may be provided, which will be used to
     * disambiguate between value primitives.
     *
     * | PHP Value     | GraphQL Value        |
     * | ------------- | -------------------- |
     * | Object        | Input Object         |
     * | Assoc Array   | Input Object         |
     * | Array         | List                 |
     * | Boolean       | Boolean              |
     * | String        | String / Enum Value  |
     * | Int           | Int                  |
     * | Float         | Int / Float          |
     * | Mixed         | Enum Value           |
     * | null          | NullValue            |
     *
     * @api
     * @param $value
     * @param InputType $type
     * @return ObjectValueNode|ListValueNode|BooleanValueNode|IntValueNode|FloatValueNode|EnumValueNode|StringValueNode|NullValueNode
     */
    static function astFromValue(value, <InputType> type)
    {
        var astValue, tmpArray40cd750bba9870f18aada2478b24840a, itemType, valuesNodes, item, itemNode, tmpArray1526d26cce75b5841ee6bc189c8b9874, isArray, isArrayLike, fields, fieldNodes, fieldName, field, fieldValue, fieldExists, fieldNode, tmpArrayaad4359a538410c3cf3b1ad7ce45df65, tmpArraya28c29ab613795e61af0f0cdf4f9573c, tmpArray67925b0bd313acb6e9c1194e378f3aaf, serialized, tmpArray97683636499e9cd8ee7212cbe2b7aa7c, tmpArray4e23b92fdf89d851fed54fb2fd8dc14d, tmpArray95934f6ac7dcd6da9153e8fb8284ac6e, tmpArraya88ed3346ce52857017564d963b64064, tmpArraybd12505c81aceee784a08603aa1e8f32, asInt, tmpArrayd83cbcc6a0c26b141dd5d9cd4e7c2286, tmpArraye16508a3040d77805040225d5565ff71;
    
        if type instanceof NonNull {
            let astValue =  self::astFromValue(value, type->getWrappedType());
            if astValue instanceof NullValueNode {
                return null;
            }
            return astValue;
        }
        if value === null {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return new NullValueNode(tmpArray40cd750bba9870f18aada2478b24840a);
        }
        // Convert PHP array to GraphQL list. If the GraphQLType is a list, but
        // the value is not an array, convert the value using the list's item type.
        if type instanceof ListOfType {
            let itemType =  type->getWrappedType();
            if is_array(value) || value instanceof \Traversable {
                let valuesNodes =  [];
                for item in value {
                    let itemNode =  self::astFromValue(item, itemType);
                    if itemNode {
                        let valuesNodes[] = itemNode;
                    }
                }
                let tmpArray1526d26cce75b5841ee6bc189c8b9874 = ["values" : valuesNodes];
                return new ListValueNode(tmpArray1526d26cce75b5841ee6bc189c8b9874);
            }
            return self::astFromValue(value, itemType);
        }
        // Populate the fields of the input object by creating ASTs from each value
        // in the PHP object according to the fields in the input type.
        if type instanceof InputObjectType {
            let isArray =  is_array(value);
            let isArrayLike =  isArray || value instanceof \ArrayAccess;
            if value === null || !(isArrayLike) && !(is_object(value)) {
                return null;
            }
            let fields =  type->getFields();
            let fieldNodes =  [];
            for fieldName, field in fields {
                if isArrayLike {
                    let fieldValue =  isset value[fieldName] ? value[fieldName]  : null;
                } else {
                    let fieldValue =  isset value->{fieldName} ? value->{fieldName}  : null;
                }
                // Have to check additionally if key exists, since we differentiate between
                // "no key" and "value is null":
                if fieldValue !== null {
                    let fieldExists =  true;
                } else {
                    if isArray {
                        let fieldExists =  array_key_exists(fieldName, value);
                    } else {
                        if isArrayLike {
                            /** @var \ArrayAccess $value */
                            let fieldExists =  value->offsetExists(fieldName);
                        } else {
                            let fieldExists =  property_exists(value, fieldName);
                        }
                    }
                }
                if fieldExists {
                    let fieldNode =  self::astFromValue(fieldValue, field->getType());
                    if fieldNode {
                        let fieldNodes[] = new ObjectFieldNode(["name" : new NameNode(tmpArraya28c29ab613795e61af0f0cdf4f9573c), "value" : fieldNode]);
                    }
                }
            }
            let tmpArray67925b0bd313acb6e9c1194e378f3aaf = ["fields" : fieldNodes];
            return new ObjectValueNode(tmpArray67925b0bd313acb6e9c1194e378f3aaf);
        }
        if type instanceof ScalarType || type instanceof EnumType {
            // Since value is an internally represented value, it must be serialized
            // to an externally represented value before converting into an AST.
            let serialized =  type->serialize(value);
            if serialized === null || Utils::isInvalid(serialized) {
                return null;
            }
            // Others serialize based on their corresponding PHP scalar types.
            if is_bool(serialized) {
                let tmpArray97683636499e9cd8ee7212cbe2b7aa7c = ["value" : serialized];
                return new BooleanValueNode(tmpArray97683636499e9cd8ee7212cbe2b7aa7c);
            }
            if is_int(serialized) {
                let tmpArray4e23b92fdf89d851fed54fb2fd8dc14d = ["value" : serialized];
                return new IntValueNode(tmpArray4e23b92fdf89d851fed54fb2fd8dc14d);
            }
            if is_float(serialized) {
                if (int) serialized == serialized {
                    let tmpArray95934f6ac7dcd6da9153e8fb8284ac6e = ["value" : serialized];
                    return new IntValueNode(tmpArray95934f6ac7dcd6da9153e8fb8284ac6e);
                }
                let tmpArraya88ed3346ce52857017564d963b64064 = ["value" : serialized];
                return new FloatValueNode(tmpArraya88ed3346ce52857017564d963b64064);
            }
            if is_string(serialized) {
                // Enum types use Enum literals.
                if type instanceof EnumType {
                    let tmpArraybd12505c81aceee784a08603aa1e8f32 = ["value" : serialized];
                    return new EnumValueNode(tmpArraybd12505c81aceee784a08603aa1e8f32);
                }
                // ID types can use Int literals.
                let asInt =  (int) serialized;
                if type instanceof IDType && (string) asInt === serialized {
                    let tmpArrayd83cbcc6a0c26b141dd5d9cd4e7c2286 = ["value" : serialized];
                    return new IntValueNode(tmpArrayd83cbcc6a0c26b141dd5d9cd4e7c2286);
                }
                // Use json_encode, which uses the same string encoding as GraphQL,
                // then remove the quotes.
                let tmpArraye16508a3040d77805040225d5565ff71 = ["value" : substr(json_encode(serialized), 1, -1)];
                return new StringValueNode(tmpArraye16508a3040d77805040225d5565ff71);
            }
            throw new InvariantViolation("Cannot convert value to AST: " . Utils::printSafe(serialized));
        }
        throw new Error("Unknown type: " . Utils::printSafe(type) . ".");
    }
    
    /**
     * Produces a PHP value given a GraphQL Value AST.
     *
     * A GraphQL type must be provided, which will be used to interpret different
     * GraphQL Value literals.
     *
     * Returns `null` when the value could not be validly coerced according to
     * the provided type.
     *
     * | GraphQL Value        | PHP Value     |
     * | -------------------- | ------------- |
     * | Input Object         | Assoc Array   |
     * | List                 | Array         |
     * | Boolean              | Boolean       |
     * | String               | String        |
     * | Int / Float          | Int / Float   |
     * | Enum Value           | Mixed         |
     * | Null Value           | null          |
     *
     * @api
     * @param $valueNode
     * @param InputType $type
     * @param null $variables
     * @return array|null|\stdClass
     * @throws \Exception
     */
    public static function valueFromAST(valueNode, <InputType> type, null variables = null)
    {
        var undefined, variableName, itemType, coercedValues, itemNodes, itemNode, itemValue, coercedValue, tmpArray040809529c4a6f89ec2d627344b5a69b, coercedObj, fields, fieldNodes, field, fieldName, fieldNode, fieldValue, enumValue, result, error;
    
        let undefined =  Utils::undefined();
        if !(valueNode) {
            // When there is no AST, then there is also no value.
            // Importantly, this is different from returning the GraphQL null value.
            return undefined;
        }
        if type instanceof NonNull {
            if valueNode instanceof NullValueNode {
                // Invalid: intentionally return no value.
                return undefined;
            }
            return self::valueFromAST(valueNode, type->getWrappedType(), variables);
        }
        if valueNode instanceof NullValueNode {
            // This is explicitly returning the value null.
            return null;
        }
        if valueNode instanceof VariableNode {
            let variableName =  valueNode->name->value;
            if !(variables) || !(array_key_exists(variableName, variables)) {
                // No valid return value.
                return undefined;
            }
            // Note: we're not doing any checking that this variable is correct. We're
            // assuming that this query has been validated and the variable usage here
            // is of the correct type.
            return variables[variableName];
        }
        if type instanceof ListOfType {
            let itemType =  type->getWrappedType();
            if valueNode instanceof ListValueNode {
                let coercedValues =  [];
                let itemNodes =  valueNode->values;
                for itemNode in itemNodes {
                    if self::isMissingVariable(itemNode, variables) {
                        // If an array contains a missing variable, it is either coerced to
                        // null or if the item type is non-null, it considered invalid.
                        if itemType instanceof NonNull {
                            // Invalid: intentionally return no value.
                            return undefined;
                        }
                        let coercedValues[] = null;
                    } else {
                        let itemValue =  self::valueFromAST(itemNode, itemType, variables);
                        if undefined === itemValue {
                            // Invalid: intentionally return no value.
                            return undefined;
                        }
                        let coercedValues[] = itemValue;
                    }
                }
                return coercedValues;
            }
            let coercedValue =  self::valueFromAST(valueNode, itemType, variables);
            if undefined === coercedValue {
                // Invalid: intentionally return no value.
                return undefined;
            }
            let tmpArray040809529c4a6f89ec2d627344b5a69b = [coercedValue];
            return tmpArray040809529c4a6f89ec2d627344b5a69b;
        }
        if type instanceof InputObjectType {
            if !(valueNode instanceof ObjectValueNode) {
                // Invalid: intentionally return no value.
                return undefined;
            }
            let coercedObj =  [];
            let fields =  type->getFields();
            let fieldNodes =  Utils::keyMap(valueNode->fields, new astvalueFromASTClosureOne());
            for field in fields {
                /** @var ValueNode $fieldNode */
                let fieldName =  field->name;
                let fieldNode =  isset fieldNodes[fieldName] ? fieldNodes[fieldName]  : null;
                if !(fieldNode) || self::isMissingVariable(fieldNode->value, variables) {
                    if field->defaultValueExists() {
                        let coercedObj[fieldName] = field->defaultValue;
                    } else {
                        if field->getType() instanceof NonNull {
                            // Invalid: intentionally return no value.
                            return undefined;
                        }
                    }
                    continue;
                }
                let fieldValue =  self::valueFromAST( fieldNode ? fieldNode->value  : null, field->getType(), variables);
                if undefined === fieldValue {
                    // Invalid: intentionally return no value.
                    return undefined;
                }
                let coercedObj[fieldName] = fieldValue;
            }
            return coercedObj;
        }
        if type instanceof EnumType {
            if !(valueNode instanceof EnumValueNode) {
                return undefined;
            }
            let enumValue =  type->getValue(valueNode->value);
            if !(enumValue) {
                return undefined;
            }
            return enumValue->value;
        }
        if type instanceof ScalarType {
            // Scalars fulfill parsing a literal value via parseLiteral().
            // Invalid values represent a failure to parse correctly, in which case
            // no value is returned.
            try {
                let result =  type->parseLiteral(valueNode, variables);
            } catch \Exception, error {
                return undefined;
            } catch \Throwable, error {
                return undefined;
            }
            if Utils::isInvalid(result) {
                return undefined;
            }
            return result;
        }
        throw new Error("Unknown type: " . Utils::printSafe(type) . ".");
    }
    
    /**
     * Produces a PHP value given a GraphQL Value AST.
     *
     * Unlike `valueFromAST()`, no type is provided. The resulting JavaScript value
     * will reflect the provided GraphQL value AST.
     *
     * | GraphQL Value        | PHP Value     |
     * | -------------------- | ------------- |
     * | Input Object         | Assoc Array   |
     * | List                 | Array         |
     * | Boolean              | Boolean       |
     * | String               | String        |
     * | Int / Float          | Int / Float   |
     * | Enum                 | Mixed         |
     * | Null                 | null          |
     *
     * @api
     * @param Node $valueNode
     * @param array|null $variables
     * @return mixed
     * @throws \Exception
     */
    public static function valueFromASTUntyped(<Node> valueNode, array variables = null)
    {
        var variableName;
    
        if valueNode instanceof NullValueNode {
            return null;
        } elseif valueNode instanceof ObjectValueNode {
            return array_combine(array_map(new astvalueFromASTUntypedClosureOne(), iterator_to_array(valueNode->fields)), array_map(new astvalueFromASTUntypedClosureOne(variables), iterator_to_array(valueNode->fields)));
        } elseif valueNode instanceof ListValueNode {
            return array_map(new astvalueFromASTUntypedClosureOne(variables), iterator_to_array(valueNode->values));
        } elseif valueNode instanceof StringValueNode || valueNode instanceof EnumValueNode || valueNode instanceof BooleanValueNode {
            return valueNode->value;
        } elseif valueNode instanceof FloatValueNode {
            return floatval(valueNode->value);
        } elseif valueNode instanceof IntValueNode {
            return intval(valueNode->value, 10);
        } else {
            let variableName =  valueNode->name->value;
            return  variables && isset variables[variableName] && !(Utils::isInvalid(variables[variableName])) ? variables[variableName]  : null;
        }
        throw new Error("Unexpected value kind: " . valueNode->kind . ".");
    }
    
    /**
     * Returns type definition for given AST Type node
     *
     * @api
     * @param Schema $schema
     * @param NamedTypeNode|ListTypeNode|NonNullTypeNode $inputTypeNode
     * @return Type
     * @throws \Exception
     */
    public static function typeFromAST(<Schema> schema, inputTypeNode) -> <Type>
    {
        var innerType;
    
        if inputTypeNode instanceof ListTypeNode {
            let innerType =  self::typeFromAST(schema, inputTypeNode->type);
            return  innerType ? new ListOfType(innerType)  : null;
        }
        if inputTypeNode instanceof NonNullTypeNode {
            let innerType =  self::typeFromAST(schema, inputTypeNode->type);
            return  innerType ? new NonNull(innerType)  : null;
        }
        if inputTypeNode instanceof NamedTypeNode {
            return schema->getType(inputTypeNode->name->value);
        }
        throw new Error("Unexpected type kind: " . inputTypeNode->kind . ".");
    }
    
    /**
     * Returns true if the provided valueNode is a variable which is not defined
     * in the set of variables.
     * @param $valueNode
     * @param $variables
     * @return bool
     */
    protected static function isMissingVariable(valueNode, variables) -> bool
    {
        return valueNode instanceof VariableNode && (!(variables) || !(array_key_exists(valueNode->name->value, variables)));
    }
    
    /**
     * Returns operation type ("query", "mutation" or "subscription") given a document and operation name
     *
     * @api
     * @param DocumentNode $document
     * @param string $operationName
     * @return bool
     */
    public static function getOperation(<DocumentNode> document, string operationName = null) -> bool
    {
        var def;
    
        if document->definitions {
            for def in document->definitions {
                if def instanceof OperationDefinitionNode {
                    if !(operationName) || isset def->name->value && def->name->value === operationName {
                        return def->operation;
                    }
                }
            }
        }
        return false;
    }

}