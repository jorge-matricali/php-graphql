namespace GraphQL\Type;

use GraphQL\Language\Printer;
use GraphQL\Type\Definition\Directive;
use GraphQL\Language\DirectiveLocation;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\FieldArgument;
use GraphQL\Type\Definition\FieldDefinition;
use GraphQL\Type\Definition\InputObjectField;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Definition\WrappingType;
use GraphQL\Utils\Utils;
use GraphQL\Utils\AST;
class Introspection
{
    protected static map = [];
    /**
     * Options:
     *   - descriptions
     *     Whether to include descriptions in the introspection result.
     *     Default: true
     *
     * @param array $options
     * @return string
     */
    public static function getIntrospectionQuery(array options = []) -> string
    {
        var descriptions, descriptionField;
    
        if is_bool(options) {
            trigger_error("Calling Introspection::getIntrospectionQuery(boolean) is deprecated. Please use Introspection::getIntrospectionQuery([\"descriptions\" => boolean]).", E_USER_DEPRECATED);
            let descriptions = options;
        } else {
            let descriptions =  !(array_key_exists("descriptions", options)) || options["descriptions"] === true;
        }
        let descriptionField =  descriptions ? "description"  : "";
        return "  query IntrospectionQuery {\n    __schema {\n      queryType { name }\n      mutationType { name }\n      subscriptionType { name }\n      types {\n        ...FullType\n      }\n      directives {\n        name\n        {descriptionField}\n        locations\n        args {\n          ...InputValue\n        }\n      }\n    }\n  }\n\n  fragment FullType on __Type {\n    kind\n    name\n    {descriptionField}\n    fields(includeDeprecated: true) {\n      name\n      {descriptionField}\n      args {\n        ...InputValue\n      }\n      type {\n        ...TypeRef\n      }\n      isDeprecated\n      deprecationReason\n    }\n    inputFields {\n      ...InputValue\n    }\n    interfaces {\n      ...TypeRef\n    }\n    enumValues(includeDeprecated: true) {\n      name\n      {descriptionField}\n      isDeprecated\n      deprecationReason\n    }\n    possibleTypes {\n      ...TypeRef\n    }\n  }\n\n  fragment InputValue on __InputValue {\n    name\n    {descriptionField}\n    type { ...TypeRef }\n    defaultValue\n  }\n\n  fragment TypeRef on __Type {\n    kind\n    name\n    ofType {\n      kind\n      name\n      ofType {\n        kind\n        name\n        ofType {\n          kind\n          name\n          ofType {\n            kind\n            name\n            ofType {\n              kind\n              name\n              ofType {\n                kind\n                name\n                ofType {\n                  kind\n                  name\n                }\n              }\n            }\n          }\n        }\n      }\n    }\n  }";
    }
    
    public static function getTypes()
    {
        var tmpArrayd934db1228b2fb373f2883f8a0ab2f00;
    
        let tmpArrayd934db1228b2fb373f2883f8a0ab2f00 = ["__Schema" : self::_schema(), "__Type" : self::_type(), "__Directive" : self::_directive(), "__Field" : self::_field(), "__InputValue" : self::_inputValue(), "__EnumValue" : self::_enumValue(), "__TypeKind" : self::_typeKind(), "__DirectiveLocation" : self::_directiveLocation()];
        return tmpArrayd934db1228b2fb373f2883f8a0ab2f00;
    }
    
    /**
     * @param Type $type
     * @return bool
     */
    public static function isIntrospectionType(<Type> type) -> bool
    {
        return in_array(type->name, array_keys(self::getTypes()));
    }
    
    public static function _schema()
    {
        var tmpArraye6b865e39ae41f223e195a79f65d97a7;
    
        if !(isset self::map["__Schema"]) {
            let self::map["__Schema"] = new ObjectType(["name" : "__Schema", "isIntrospection" : true, "description" : "A GraphQL Schema defines the capabilities of a GraphQL " . "server. It exposes all available types and directives on " . "the server, as well as the entry points for query, mutation, and " . "subscription operations.", "fields" : ["types" : ["description" : "A list of all types supported by this server.", "type" : new NonNull(new ListOfType(new NonNull(self::_type()))), "resolve" : new Introspection_schemaClosureOne()], "queryType" : ["description" : "The type that query operations will be rooted at.", "type" : new NonNull(self::_type()), "resolve" : new Introspection_schemaClosureOne()], "mutationType" : ["description" : "If this server supports mutation, the type that " . "mutation operations will be rooted at.", "type" : self::_type(), "resolve" : new Introspection_schemaClosureOne()], "subscriptionType" : ["description" : "If this server support subscription, the type that subscription operations will be rooted at.", "type" : self::_type(), "resolve" : new Introspection_schemaClosureOne()], "directives" : ["description" : "A list of all directives supported by this server.", "type" : Type::nonNull(Type::listOf(Type::nonNull(self::_directive()))), "resolve" : new Introspection_schemaClosureOne()]]]);
        }
        return self::map["__Schema"];
    }
    
    public static function _directive()
    {
        var tmpArray17b67ce7feee286ef31e4d017c3df2de;
    
        if !(isset self::map["__Directive"]) {
            let self::map["__Directive"] = new ObjectType(["name" : "__Directive", "isIntrospection" : true, "description" : "A Directive provides a way to describe alternate runtime execution and " . "type validation behavior in a GraphQL document." . "

In some cases, you need to provide options to alter GraphQL's " . "execution behavior in ways field arguments will not suffice, such as " . "conditionally including or skipping a field. Directives provide this by " . "describing additional information to the executor.", "fields" : ["name" : ["type" : Type::nonNull(Type::string())], "description" : ["type" : Type::string()], "locations" : ["type" : Type::nonNull(Type::listOf(Type::nonNull(self::_directiveLocation())))], "args" : ["type" : Type::nonNull(Type::listOf(Type::nonNull(self::_inputValue()))), "resolve" : new Introspection_directiveClosureOne()], "onOperation" : ["deprecationReason" : "Use `locations`.", "type" : Type::nonNull(Type::boolean()), "resolve" : new Introspection_directiveClosureOne()], "onFragment" : ["deprecationReason" : "Use `locations`.", "type" : Type::nonNull(Type::boolean()), "resolve" : new Introspection_directiveClosureOne()], "onField" : ["deprecationReason" : "Use `locations`.", "type" : Type::nonNull(Type::boolean()), "resolve" : new Introspection_directiveClosureOne()]]]);
        }
        return self::map["__Directive"];
    }
    
    public static function _directiveLocation()
    {
        var tmpArray18c5651cfae2e5ccdb21d21c0cc60022;
    
        if !(isset self::map["__DirectiveLocation"]) {
            let self::map["__DirectiveLocation"] = new EnumType(["name" : "__DirectiveLocation", "isIntrospection" : true, "description" : "A Directive can be adjacent to many parts of the GraphQL language, a " . "__DirectiveLocation describes one such possible adjacencies.", "values" : ["QUERY" : ["value" : DirectiveLocation::QUERY, "description" : "Location adjacent to a query operation."], "MUTATION" : ["value" : DirectiveLocation::MUTATION, "description" : "Location adjacent to a mutation operation."], "SUBSCRIPTION" : ["value" : DirectiveLocation::SUBSCRIPTION, "description" : "Location adjacent to a subscription operation."], "FIELD" : ["value" : DirectiveLocation::FIELD, "description" : "Location adjacent to a field."], "FRAGMENT_DEFINITION" : ["value" : DirectiveLocation::FRAGMENT_DEFINITION, "description" : "Location adjacent to a fragment definition."], "FRAGMENT_SPREAD" : ["value" : DirectiveLocation::FRAGMENT_SPREAD, "description" : "Location adjacent to a fragment spread."], "INLINE_FRAGMENT" : ["value" : DirectiveLocation::INLINE_FRAGMENT, "description" : "Location adjacent to an inline fragment."], "SCHEMA" : ["value" : DirectiveLocation::SCHEMA, "description" : "Location adjacent to a schema definition."], "SCALAR" : ["value" : DirectiveLocation::SCALAR, "description" : "Location adjacent to a scalar definition."], "OBJECT" : ["value" : DirectiveLocation::OBJECT, "description" : "Location adjacent to an object type definition."], "FIELD_DEFINITION" : ["value" : DirectiveLocation::FIELD_DEFINITION, "description" : "Location adjacent to a field definition."], "ARGUMENT_DEFINITION" : ["value" : DirectiveLocation::ARGUMENT_DEFINITION, "description" : "Location adjacent to an argument definition."], "INTERFACE" : ["value" : DirectiveLocation::IFACE, "description" : "Location adjacent to an interface definition."], "UNION" : ["value" : DirectiveLocation::UNION, "description" : "Location adjacent to a union definition."], "ENUM" : ["value" : DirectiveLocation::ENUM, "description" : "Location adjacent to an enum definition."], "ENUM_VALUE" : ["value" : DirectiveLocation::ENUM_VALUE, "description" : "Location adjacent to an enum value definition."], "INPUT_OBJECT" : ["value" : DirectiveLocation::INPUT_OBJECT, "description" : "Location adjacent to an input object type definition."], "INPUT_FIELD_DEFINITION" : ["value" : DirectiveLocation::INPUT_FIELD_DEFINITION, "description" : "Location adjacent to an input object field definition."]]]);
        }
        return self::map["__DirectiveLocation"];
    }
    
    public static function _type()
    {
        var tmpArray94868bda0f8ba108c0f0a1185430691b, tmpArray2e0e4e5978854ae739efbf8e246df9d8, fields, values;
    
        if !(isset self::map["__Type"]) {
            let self::map["__Type"] = new ObjectType(let fields =  type->getFields();
            let fields =  array_filter(fields, new Introspection_typeClosureOne());
            let values =  array_values(type->getValues());
            let values =  array_filter(values, new Introspection_typeClosureOne());
            ["name" : "__Type", "isIntrospection" : true, "description" : "The fundamental unit of any GraphQL Schema is the type. There are " . "many kinds of types in GraphQL as represented by the `__TypeKind` enum." . "

" . "Depending on the kind of a type, certain fields describe " . "information about that type. Scalar types provide no information " . "beyond a name and description, while Enum types provide their values. " . "Object and Interface types provide the fields they describe. Abstract " . "types, Union and Interface, provide the Object types possible " . "at runtime. List and NonNull types compose other types.", "fields" : new Introspection_typeClosureOne()]);
        }
        return self::map["__Type"];
    }
    
    public static function _field()
    {
        var tmpArrayee804509c4e3c47154efd3d7ce6d5541, tmpArrayae7f6baf051363a6762140c8afe4eee8;
    
        if !(isset self::map["__Field"]) {
            let self::map["__Field"] = new ObjectType(["name" : "__Field", "isIntrospection" : true, "description" : "Object and Interface types are described by a list of Fields, each of " . "which has a name, potentially a list of arguments, and a return type.", "fields" : new Introspection_fieldClosureOne()]);
        }
        return self::map["__Field"];
    }
    
    public static function _inputValue()
    {
        var tmpArraycecc9e91d7a5f8c7fb8bc01a8949b10c, tmpArray73c2e67579cfe7dd4d308c2844b433bb;
    
        if !(isset self::map["__InputValue"]) {
            let self::map["__InputValue"] = new ObjectType(["name" : "__InputValue", "isIntrospection" : true, "description" : "Arguments provided to Fields or Directives and the input fields of an " . "InputObject are represented as Input Values which describe their type " . "and optionally a default value.", "fields" : new Introspection_inputValueClosureOne()]);
        }
        return self::map["__InputValue"];
    }
    
    public static function _enumValue()
    {
        var tmpArraybbd0f5cdb631ae1929d3abd81533f274;
    
        if !(isset self::map["__EnumValue"]) {
            let self::map["__EnumValue"] = new ObjectType(["name" : "__EnumValue", "isIntrospection" : true, "description" : "One possible value for a given Enum. Enum values are unique values, not " . "a placeholder for a string or numeric value. However an Enum value is " . "returned in a JSON response as a string.", "fields" : ["name" : ["type" : Type::nonNull(Type::string())], "description" : ["type" : Type::string()], "isDeprecated" : ["type" : Type::nonNull(Type::boolean()), "resolve" : new Introspection_enumValueClosureOne()], "deprecationReason" : ["type" : Type::string()]]]);
        }
        return self::map["__EnumValue"];
    }
    
    public static function _typeKind()
    {
        var tmpArray1b3008221fcc5747b5d9d8620ab1e27e;
    
        if !(isset self::map["__TypeKind"]) {
            let self::map["__TypeKind"] = new EnumType(["name" : "__TypeKind", "isIntrospection" : true, "description" : "An enum describing what kind of type a given `__Type` is.", "values" : ["SCALAR" : ["value" : TypeKind::SCALAR, "description" : "Indicates this type is a scalar."], "OBJECT" : ["value" : TypeKind::OBJECT, "description" : "Indicates this type is an object. `fields` and `interfaces` are valid fields."], "INTERFACE" : ["value" : TypeKind::INTERFACE_KIND, "description" : "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields."], "UNION" : ["value" : TypeKind::UNION, "description" : "Indicates this type is a union. `possibleTypes` is a valid field."], "ENUM" : ["value" : TypeKind::ENUM, "description" : "Indicates this type is an enum. `enumValues` is a valid field."], "INPUT_OBJECT" : ["value" : TypeKind::INPUT_OBJECT, "description" : "Indicates this type is an input object. `inputFields` is a valid field."], "LIST" : ["value" : TypeKind::LIST_KIND, "description" : "Indicates this type is a list. `ofType` is a valid field."], "NON_NULL" : ["value" : TypeKind::NON_NULL, "description" : "Indicates this type is a non-null. `ofType` is a valid field."]]]);
        }
        return self::map["__TypeKind"];
    }
    
    public static function schemaMetaFieldDef()
    {
        var tmpArray1ff07cc191355ed72e5b16099a0b6182;
    
        if !(isset self::map["__schema"]) {
            let self::map["__schema"] = FieldDefinition::create(["name" : "__schema", "type" : Type::nonNull(self::_schema()), "description" : "Access the current type schema of this server.", "args" : [], "resolve" : new IntrospectionschemaMetaFieldDefClosureOne()]);
        }
        return self::map["__schema"];
    }
    
    public static function typeMetaFieldDef()
    {
        var tmpArray3315f63d0b14adcc2052bf26ebf56b26;
    
        if !(isset self::map["__type"]) {
            let self::map["__type"] = FieldDefinition::create(["name" : "__type", "type" : self::_type(), "description" : "Request the type information of a single type.", "args" : [["name" : "name", "type" : Type::nonNull(Type::string())]], "resolve" : new IntrospectiontypeMetaFieldDefClosureOne()]);
        }
        return self::map["__type"];
    }
    
    public static function typeNameMetaFieldDef()
    {
        var tmpArrayffe042ce816d719b3dda5cfb6f0afaaa;
    
        if !(isset self::map["__typename"]) {
            let self::map["__typename"] = FieldDefinition::create(["name" : "__typename", "type" : Type::nonNull(Type::string()), "description" : "The name of the current Object type at runtime.", "args" : [], "resolve" : new IntrospectiontypeNameMetaFieldDefClosureOne()]);
        }
        return self::map["__typename"];
    }

}