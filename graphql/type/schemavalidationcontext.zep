namespace GraphQL\Type;

use GraphQL\Error\Error;
use GraphQL\Language\AST\EnumValueDefinitionNode;
use GraphQL\Language\AST\FieldDefinitionNode;
use GraphQL\Language\AST\InputValueDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeExtensionNode;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\ObjectTypeDefinitionNode;
use GraphQL\Language\AST\ObjectTypeExtensionNode;
use GraphQL\Language\AST\SchemaDefinitionNode;
use GraphQL\Language\AST\TypeDefinitionNode;
use GraphQL\Language\AST\TypeNode;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\EnumValueDefinition;
use GraphQL\Type\Definition\FieldDefinition;
use GraphQL\Type\Definition\InputObjectField;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\NamedType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Utils\TypeComparators;
use GraphQL\Utils\Utils;
class SchemaValidationContext
{
    /**
     * @var Error[]
     */
    protected errors = [];
    /**
     * @var Schema
     */
    protected schema;
    public function __construct(<Schema> schema) -> void
    {
        let this->schema = schema;
    }
    
    /**
     * @return Error[]
     */
    public function getErrors() -> array
    {
        return this->errors;
    }
    
    public function validateRootTypes() -> void
    {
        var queryType, mutationType, subscriptionType;
    
        let queryType =  this->schema->getQueryType();
        if !(queryType) {
            this->reportError("Query root type must be provided.", this->schema->getAstNode());
        } else {
            if !(queryType instanceof ObjectType) {
                this->reportError("Query root type must be Object type, it cannot be " . Utils::printSafe(queryType) . ".", this->getOperationTypeNode(queryType, "query"));
            }
        }
        let mutationType =  this->schema->getMutationType();
        if mutationType && !(mutationType instanceof ObjectType) {
            this->reportError("Mutation root type must be Object type if provided, it cannot be " . Utils::printSafe(mutationType) . ".", this->getOperationTypeNode(mutationType, "mutation"));
        }
        let subscriptionType =  this->schema->getSubscriptionType();
        if subscriptionType && !(subscriptionType instanceof ObjectType) {
            this->reportError("Subscription root type must be Object type if provided, it cannot be " . Utils::printSafe(subscriptionType) . ".", this->getOperationTypeNode(subscriptionType, "subscription"));
        }
    }
    
    /**
     * @param Type $type
     * @param string $operation
     *
     * @return TypeNode|TypeDefinitionNode
     */
    protected function getOperationTypeNode(<Type> type, string operation)
    {
        var astNode, operationTypeNode, operationType;
    
        let astNode =  this->schema->getAstNode();
        let operationTypeNode =  null;
        if astNode instanceof SchemaDefinitionNode {
            let operationTypeNode =  null;
            for operationType in astNode->operationTypes {
                if operationType->operation === operation {
                    let operationTypeNode = operationType;
                    break;
                }
            }
        }
        return  operationTypeNode ? operationTypeNode->type  : ( type ? type->astNode  : null);
    }
    
    public function validateDirectives() -> void
    {
        var directives, directive, argNames, arg, argName;
    
        let directives =  this->schema->getDirectives();
        for directive in directives {
            // Ensure all directives are in fact GraphQL directives.
            if !(directive instanceof Directive) {
                this->reportError("Expected directive but got: " . Utils::printSafe(directive) . ".",  is_object(directive) ? directive->astNode  : null);
                continue;
            }
            // Ensure they are named correctly.
            this->validateName(directive);
            // TODO: Ensure proper locations.
            let argNames =  [];
            for arg in directive->args {
                let argName =  arg->name;
                // Ensure they are named correctly.
                this->validateName(directive);
                if isset argNames[argName] {
                    this->reportError("Argument @{directive->name}({argName}:) can only be defined once.", this->getAllDirectiveArgNodes(directive, argName));
                    continue;
                }
                let argNames[argName] = true;
                // Ensure the type is an input type.
                if !(Type::isInputType(arg->getType())) {
                    this->reportError("The type of @{directive->name}({argName}:) must be Input Type " . "but got: " . Utils::printSafe(arg->getType()) . ".", this->getDirectiveArgTypeNode(directive, argName));
                }
            }
        }
    }
    
    /**
     * @param Type|Directive|FieldDefinition|EnumValueDefinition|InputObjectField $node
     */
    protected function validateName(node) -> void
    {
        var error;
    
        // Ensure names are valid, however introspection types opt out.
        let error =  Utils::isValidNameError(node->name, node->astNode);
        if error && !(Introspection::isIntrospectionType(node)) {
            this->addError(error);
        }
    }
    
    public function validateTypes() -> void
    {
        var typeMap, typeName, type;
    
        let typeMap =  this->schema->getTypeMap();
        for typeName, type in typeMap {
            // Ensure all provided types are in fact GraphQL type.
            if !(type instanceof NamedType) {
                this->reportError("Expected GraphQL named type but got: " . Utils::printSafe(type) . ".",  is_object(type) ? type->astNode  : null);
                continue;
            }
            this->validateName(type);
            if type instanceof ObjectType {
                // Ensure fields are valid
                this->validateFields(type);
                // Ensure objects implement the interfaces they claim to.
                this->validateObjectInterfaces(type);
            } else {
                if type instanceof InterfaceType {
                    // Ensure fields are valid.
                    this->validateFields(type);
                } else {
                    if type instanceof UnionType {
                        // Ensure Unions include valid member types.
                        this->validateUnionMembers(type);
                    } else {
                        if type instanceof EnumType {
                            // Ensure Enums have valid values.
                            this->validateEnumValues(type);
                        } else {
                            if type instanceof InputObjectType {
                                // Ensure Input Object fields are valid.
                                this->validateInputFields(type);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     */
    protected function validateFields(type) -> void
    {
        var fieldMap, fieldName, field, fieldNodes, argNames, arg, argName;
    
        let fieldMap =  type->getFields();
        // Objects and Interfaces both must define one or more fields.
        if !(fieldMap) {
            this->reportError("Type {type->name} must define one or more fields.", this->getAllObjectOrInterfaceNodes(type));
        }
        for fieldName, field in fieldMap {
            // Ensure they are named correctly.
            this->validateName(field);
            // Ensure they were defined at most once.
            let fieldNodes =  this->getAllFieldNodes(type, fieldName);
            if fieldNodes && count(fieldNodes) > 1 {
                this->reportError("Field {type->name}.{fieldName} can only be defined once.", fieldNodes);
                continue;
            }
            // Ensure the type is an output type
            if !(Type::isOutputType(field->getType())) {
                this->reportError("The type of {type->name}.{fieldName} must be Output Type " . "but got: " . Utils::printSafe(field->getType()) . ".", this->getFieldTypeNode(type, fieldName));
            }
            // Ensure the arguments are valid
            let argNames =  [];
            for arg in field->args {
                let argName =  arg->name;
                // Ensure they are named correctly.
                this->validateName(arg);
                if isset argNames[argName] {
                    this->reportError("Field argument {type->name}.{fieldName}({argName}:) can only " . "be defined once.", this->getAllFieldArgNodes(type, fieldName, argName));
                }
                let argNames[argName] = true;
                // Ensure the type is an input type
                if !(Type::isInputType(arg->getType())) {
                    this->reportError("The type of {type->name}.{fieldName}({argName}:) must be Input " . "Type but got: " . Utils::printSafe(arg->getType()) . ".", this->getFieldArgTypeNode(type, fieldName, argName));
                }
            }
        }
    }
    
    protected function validateObjectInterfaces(<ObjectType> object) -> void
    {
        var implementedTypeNames, iface;
    
        let implementedTypeNames =  [];
        for iface in object->getInterfaces() {
            if isset implementedTypeNames[iface->name] {
                this->reportError("Type {object->name} can only implement {iface->name} once.", this->getAllImplementsInterfaceNodes(object, iface));
                continue;
            }
            let implementedTypeNames[iface->name] = true;
            this->validateObjectImplementsInterface(object, iface);
        }
    }
    
    /**
     * @param ObjectType $object
     * @param InterfaceType $iface
     */
    protected function validateObjectImplementsInterface(<ObjectType> object, <InterfaceType> iface)
    {
        var objectFieldMap, ifaceFieldMap, fieldName, ifaceField, objectField, tmpArray69bbcbb5c88c6737c62171d3508533b0, tmpArraycc668730c09602c51817493f40a494fd, ifaceArg, argName, objectArg, arg, tmpArray6d0a8de0e305e81e433f11aaf93f1efe, tmpArrayd29d0b67e954ea08ace26ad8a3739b8f, tmpArraybaa458c931399b63d71dcdaee0fe9280;
    
        if !(iface instanceof InterfaceType) {
            this->reportError("Type {object->name} must only implement Interface types, " . "it cannot implement " . Utils::printSafe(iface) . ".", this->getImplementsInterfaceNode(object, iface));
            return;
        }
        let objectFieldMap =  object->getFields();
        let ifaceFieldMap =  iface->getFields();
        // Assert each interface field is implemented.
        for fieldName, ifaceField in ifaceFieldMap {
            let objectField =  array_key_exists(fieldName, objectFieldMap) ? objectFieldMap[fieldName]  : null;
            // Assert interface field exists on object.
            if !(objectField) {
                let tmpArray69bbcbb5c88c6737c62171d3508533b0 = [this->getFieldNode(iface, fieldName), object->astNode];
                this->reportError("Interface field {iface->name}.{fieldName} expected but " . "{object->name} does not provide it.", tmpArray69bbcbb5c88c6737c62171d3508533b0);
                continue;
            }
            // Assert interface field type is satisfied by object field type, by being
            // a valid subtype. (covariant)
            if !(TypeComparators::isTypeSubTypeOf(this->schema, objectField->getType(), ifaceField->getType())) {
                let tmpArraycc668730c09602c51817493f40a494fd = [this->getFieldTypeNode(iface, fieldName), this->getFieldTypeNode(object, fieldName)];
                this->reportError("Interface field {iface->name}.{fieldName} expects type " . "{ifaceField->getType()} but {object->name}.{fieldName} " . "is type " . Utils::printSafe(objectField->getType()) . ".", tmpArraycc668730c09602c51817493f40a494fd);
            }
            // Assert each interface field arg is implemented.
            for ifaceArg in ifaceField->args {
                let argName =  ifaceArg->name;
                let objectArg =  null;
                for arg in objectField->args {
                    if arg->name === argName {
                        let objectArg = arg;
                        break;
                    }
                }
                // Assert interface field arg exists on object field.
                if !(objectArg) {
                    let tmpArray6d0a8de0e305e81e433f11aaf93f1efe = [this->getFieldArgNode(iface, fieldName, argName), this->getFieldNode(object, fieldName)];
                    this->reportError("Interface field argument {iface->name}.{fieldName}({argName}:) " . "expected but {object->name}.{fieldName} does not provide it.", tmpArray6d0a8de0e305e81e433f11aaf93f1efe);
                    continue;
                }
                // Assert interface field arg type matches object field arg type.
                // (invariant)
                // TODO: change to contravariant?
                if !(TypeComparators::isEqualType(ifaceArg->getType(), objectArg->getType())) {
                    let tmpArrayd29d0b67e954ea08ace26ad8a3739b8f = [this->getFieldArgTypeNode(iface, fieldName, argName), this->getFieldArgTypeNode(object, fieldName, argName)];
                    this->reportError("Interface field argument {iface->name}.{fieldName}({argName}:) " . "expects type " . Utils::printSafe(ifaceArg->getType()) . " but " . "{object->name}.{fieldName}({argName}:) is type " . Utils::printSafe(objectArg->getType()) . ".", tmpArrayd29d0b67e954ea08ace26ad8a3739b8f);
                }
            }
            // Assert additional arguments must not be required.
            for objectArg in objectField->args {
                let argName =  objectArg->name;
                let ifaceArg =  null;
                for arg in ifaceField->args {
                    if arg->name === argName {
                        let ifaceArg = arg;
                        break;
                    }
                }
                if !(ifaceArg) && objectArg->getType() instanceof NonNull {
                    let tmpArraybaa458c931399b63d71dcdaee0fe9280 = [this->getFieldArgTypeNode(object, fieldName, argName), this->getFieldNode(iface, fieldName)];
                    this->reportError("Object field argument {object->name}.{fieldName}({argName}:) " . "is of required type " . Utils::printSafe(objectArg->getType()) . " but is not also " . "provided by the Interface field {iface->name}.{fieldName}.", tmpArraybaa458c931399b63d71dcdaee0fe9280);
                }
            }
        }
    }
    
    protected function validateUnionMembers(<UnionType> union) -> void
    {
        var memberTypes, includedTypeNames, memberType;
    
        let memberTypes =  union->getTypes();
        if !(memberTypes) {
            this->reportError("Union type {union->name} must define one or more member types.", union->astNode);
        }
        let includedTypeNames =  [];
        for memberType in memberTypes {
            if isset includedTypeNames[memberType->name] {
                this->reportError("Union type {union->name} can only include type " . "{memberType->name} once.", this->getUnionMemberTypeNodes(union, memberType->name));
                continue;
            }
            let includedTypeNames[memberType->name] = true;
            if !(memberType instanceof ObjectType) {
                this->reportError("Union type {union->name} can only include Object types, " . "it cannot include " . Utils::printSafe(memberType) . ".", this->getUnionMemberTypeNodes(union, Utils::printSafe(memberType)));
            }
        }
    }
    
    protected function validateEnumValues(<EnumType> enumType) -> void
    {
        var enumValues, enumValue, valueName, allNodes;
    
        let enumValues =  enumType->getValues();
        if !(enumValues) {
            this->reportError("Enum type {enumType->name} must define one or more values.", enumType->astNode);
        }
        for enumValue in enumValues {
            let valueName =  enumValue->name;
            // Ensure no duplicates
            let allNodes =  this->getEnumValueNodes(enumType, valueName);
            if allNodes && count(allNodes) > 1 {
                this->reportError("Enum type {enumType->name} can include value {valueName} only once.", allNodes);
            }
            // Ensure valid name.
            this->validateName(enumValue);
            if valueName === "true" || valueName === "false" || valueName === "null" {
                this->reportError("Enum type {enumType->name} cannot include value: {valueName}.", enumValue->astNode);
            }
        }
    }
    
    protected function validateInputFields(<InputObjectType> inputObj) -> void
    {
        var fieldMap, fieldName, field;
    
        let fieldMap =  inputObj->getFields();
        if !(fieldMap) {
            this->reportError("Input Object type {inputObj->name} must define one or more fields.", inputObj->astNode);
        }
        // Ensure the arguments are valid
        for fieldName, field in fieldMap {
            // Ensure they are named correctly.
            this->validateName(field);
            // TODO: Ensure they are unique per field.
            // Ensure the type is an input type
            if !(Type::isInputType(field->getType())) {
                this->reportError("The type of {inputObj->name}.{fieldName} must be Input Type " . "but got: " . Utils::printSafe(field->getType()) . ".",  field->astNode ? field->astNode->type  : null);
            }
        }
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @return ObjectTypeDefinitionNode[]|ObjectTypeExtensionNode[]|InterfaceTypeDefinitionNode[]|InterfaceTypeExtensionNode[]
     */
    protected function getAllObjectOrInterfaceNodes(type)
    {
        var tmpArray93fff130ee85b696a715b931aabbae98;
    
        let tmpArray93fff130ee85b696a715b931aabbae98 = [type->astNode];
        let tmpArray3af7ca23d93c896a976048b05fa41750 = [type->astNode];
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  type->astNode ?  type->extensionASTNodes ? array_merge(tmpArray93fff130ee85b696a715b931aabbae98, type->extensionASTNodes)  : tmpArray3af7ca23d93c896a976048b05fa41750  : ( type->extensionASTNodes ? type->extensionASTNodes : tmpArray40cd750bba9870f18aada2478b24840a);
    }
    
    /**
     * @param ObjectType $type
     * @param InterfaceType $iface
     * @return NamedTypeNode|null
     */
    protected function getImplementsInterfaceNode(<ObjectType> type, <InterfaceType> iface)
    {
        var nodes;
    
        let nodes =  this->getAllImplementsInterfaceNodes(type, iface);
        return  nodes && isset nodes[0] ? nodes[0]  : null;
    }
    
    /**
     * @param ObjectType $type
     * @param InterfaceType $iface
     * @return NamedTypeNode[]
     */
    protected function getAllImplementsInterfaceNodes(<ObjectType> type, <InterfaceType> iface) -> array
    {
        var implementsNodes, astNodes, astNode, node;
    
        let implementsNodes =  [];
        let astNodes =  this->getAllObjectOrInterfaceNodes(type);
        for astNode in astNodes {
            if astNode && astNode->interfaces {
                for node in astNode->interfaces {
                    if node->name->value === iface->name {
                        let implementsNodes[] = node;
                    }
                }
            }
        }
        return implementsNodes;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @return FieldDefinitionNode|null
     */
    protected function getFieldNode(type, string fieldName)
    {
        var nodes;
    
        let nodes =  this->getAllFieldNodes(type, fieldName);
        return  nodes && isset nodes[0] ? nodes[0]  : null;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @return FieldDefinitionNode[]
     */
    protected function getAllFieldNodes(type, string fieldName) -> array
    {
        var fieldNodes, astNodes, astNode, node;
    
        let fieldNodes =  [];
        let astNodes =  this->getAllObjectOrInterfaceNodes(type);
        for astNode in astNodes {
            if astNode && astNode->fields {
                for node in astNode->fields {
                    if node->name->value === fieldName {
                        let fieldNodes[] = node;
                    }
                }
            }
        }
        return fieldNodes;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @return TypeNode|null
     */
    protected function getFieldTypeNode(type, string fieldName)
    {
        var fieldNode;
    
        let fieldNode =  this->getFieldNode(type, fieldName);
        return  fieldNode ? fieldNode->type  : null;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @param string $argName
     * @return InputValueDefinitionNode|null
     */
    protected function getFieldArgNode(type, string fieldName, string argName)
    {
        var nodes;
    
        let nodes =  this->getAllFieldArgNodes(type, fieldName, argName);
        return  nodes && isset nodes[0] ? nodes[0]  : null;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @param string $argName
     * @return InputValueDefinitionNode[]
     */
    protected function getAllFieldArgNodes(type, string fieldName, string argName) -> array
    {
        var argNodes, fieldNode, node;
    
        let argNodes =  [];
        let fieldNode =  this->getFieldNode(type, fieldName);
        if fieldNode && fieldNode->arguments {
            for node in fieldNode->arguments {
                if node->name->value === argName {
                    let argNodes[] = node;
                }
            }
        }
        return argNodes;
    }
    
    /**
     * @param ObjectType|InterfaceType $type
     * @param string $fieldName
     * @param string $argName
     * @return TypeNode|null
     */
    protected function getFieldArgTypeNode(type, string fieldName, string argName)
    {
        var fieldArgNode;
    
        let fieldArgNode =  this->getFieldArgNode(type, fieldName, argName);
        return  fieldArgNode ? fieldArgNode->type  : null;
    }
    
    /**
     * @param Directive $directive
     * @param string $argName
     * @return InputValueDefinitionNode[]
     */
    protected function getAllDirectiveArgNodes(<Directive> directive, string argName) -> array
    {
        var argNodes, directiveNode, node;
    
        let argNodes =  [];
        let directiveNode =  directive->astNode;
        if directiveNode && directiveNode->arguments {
            for node in directiveNode->arguments {
                if node->name->value === argName {
                    let argNodes[] = node;
                }
            }
        }
        return argNodes;
    }
    
    /**
     * @param Directive $directive
     * @param string $argName
     * @return TypeNode|null
     */
    protected function getDirectiveArgTypeNode(<Directive> directive, string argName)
    {
        var argNode;
    
        let argNode = this->getAllDirectiveArgNodes(directive, argName)[0];
        return  argNode ? argNode->type  : null;
    }
    
    /**
     * @param UnionType $union
     * @param string $typeName
     * @return NamedTypeNode[]
     */
    protected function getUnionMemberTypeNodes(<UnionType> union, string typeName) -> array
    {
        if union->astNode && union->astNode->types {
            return array_filter(union->astNode->types, new SchemaValidationContextgetUnionMemberTypeNodesClosureOne(typeName));
        }
        return  union->astNode ? union->astNode->types  : null;
    }
    
    /**
     * @param EnumType $enum
     * @param string $valueName
     * @return EnumValueDefinitionNode[]
     */
    protected function getEnumValueNodes(<EnumType> enumm, string valueName) -> array
    {
        if enumm->astNode && enumm->astNode->values {
            return array_filter(iterator_to_array(enumm->astNode->values), new SchemaValidationContextgetEnumValueNodesClosureOne(valueName));
        }
        return  enumm->astNode ? enumm->astNode->values  : null;
    }
    
    /**
     * @param string $message
     * @param array|Node|TypeNode|TypeDefinitionNode $nodes
     */
    protected function reportError(string message, nodes = null) -> void
    {
        let tmpArray34d12ead4c53c9110e49b73190c78e22 = [nodes];
        let nodes =  array_filter( nodes && is_array(nodes) ? nodes  : tmpArray34d12ead4c53c9110e49b73190c78e22);
        this->addError(new Error(message, nodes));
    }
    
    /**
     * @param Error $error
     */
    protected function addError(<\Error> error) -> void
    {
        let this->errors[] = error;
    }

}