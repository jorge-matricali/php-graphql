namespace GraphQL\Utils;

use GraphQL\Error\Error;
use GraphQL\Executor\Values;
use GraphQL\Language\AST\DirectiveDefinitionNode;
use GraphQL\Language\AST\EnumTypeDefinitionNode;
use GraphQL\Language\AST\EnumValueDefinitionNode;
use GraphQL\Language\AST\FieldDefinitionNode;
use GraphQL\Language\AST\InputObjectTypeDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeDefinitionNode;
use GraphQL\Language\AST\ListTypeNode;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NonNullTypeNode;
use GraphQL\Language\AST\ObjectTypeDefinitionNode;
use GraphQL\Language\AST\ScalarTypeDefinitionNode;
use GraphQL\Language\AST\TypeNode;
use GraphQL\Language\AST\UnionTypeDefinitionNode;
use GraphQL\Language\Token;
use GraphQL\Type\Definition\CustomScalarType;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InputType;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\FieldArgument;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
class ASTDefinitionBuilder
{
    /**
     * @var array
     */
    protected typeDefintionsMap;
    /**
     * @var callable
     */
    protected typeConfigDecorator;
    /**
     * @var array
     */
    protected options;
    /**
     * @var callable
     */
    protected resolveType;
    /**
     * @var array
     */
    protected cache;
    public function __construct(array typeDefintionsMap, options, resolveType, typeConfigDecorator = null) -> void
    {
        let this->typeDefintionsMap = typeDefintionsMap;
        let this->typeConfigDecorator = typeConfigDecorator;
        let this->options = options;
        let this->resolveType = resolveType;
        let this->cache =  Type::getAllBuiltInTypes();
    }
    
    /**
     * @param Type $innerType
     * @param TypeNode|ListTypeNode|NonNullTypeNode $inputTypeNode
     * @return Type
     */
    protected function buildWrappedType(<Type> innerType, <TypeNode> inputTypeNode) -> <Type>
    {
        var wrappedType;
    
        if inputTypeNode->kind == NodeKind::LIST_TYPE {
            return Type::listOf(this->buildWrappedType(innerType, inputTypeNode->type));
        }
        if inputTypeNode->kind == NodeKind::NON_NULL_TYPE {
            let wrappedType =  this->buildWrappedType(innerType, inputTypeNode->type);
            return Type::nonNull(NonNull::assertNullableType(wrappedType));
        }
        return innerType;
    }
    
    /**
     * @param TypeNode|ListTypeNode|NonNullTypeNode $typeNode
     * @return TypeNode
     */
    protected function getNamedTypeNode(<TypeNode> typeNode) -> <TypeNode>
    {
        var namedType;
    
        let namedType = typeNode;
        while (namedType->kind === NodeKind::LIST_TYPE || namedType->kind === NodeKind::NON_NULL_TYPE) {
            let namedType =  namedType->type;
        }
        return namedType;
    }
    
    /**
     * @param string $typeName
     * @param NamedTypeNode|null $typeNode
     * @return Type
     * @throws Error
     */
    protected function internalBuildType(string typeName, typeNode = null) -> <Type>
    {
        var type, fn, config, e;
    
        if !(isset this->cache[typeName]) {
            if isset this->typeDefintionsMap[typeName] {
                let type =  this->makeSchemaDef(this->typeDefintionsMap[typeName]);
                if this->typeConfigDecorator {
                    let fn =  this->typeConfigDecorator;
                    try {
                        let config =  {fn}(type->config, this->typeDefintionsMap[typeName], this->typeDefintionsMap);
                    } catch \Exception, e {
                        throw new Error("Type config decorator passed to " . static::class . " threw an error " . "when building {typeName} type: {e->getMessage()}", null, null, null, null, e);
                    } catch \Throwable, e {
                        throw new Error("Type config decorator passed to " . static::class . " threw an error " . "when building {typeName} type: {e->getMessage()}", null, null, null, null, e);
                    }
                    if !(is_array(config)) || isset config[0] {
                        throw new Error("Type config decorator passed to " . static::class . " is expected to return an array, but got " . Utils::getVariableType(config));
                    }
                    let type =  this->makeSchemaDefFromConfig(this->typeDefintionsMap[typeName], config);
                }
                let this->cache[typeName] = type;
            } else {
                let fn =  this->resolveType;
                let this->cache[typeName] =  {fn}(typeName, typeNode);
            }
        }
        return this->cache[typeName];
    }
    
    /**
     * @param string|NamedTypeNode $ref
     * @return Type
     * @throws Error
     */
    public function buildType(ref) -> <Type>
    {
        if is_string(ref) {
            return this->internalBuildType(ref);
        }
        return this->internalBuildType(ref->name->value, ref);
    }
    
    /**
     * @param TypeNode $typeNode
     * @return Type|InputType
     * @throws Error
     */
    protected function internalBuildWrappedType(<TypeNode> typeNode)
    {
        var typeDef;
    
        let typeDef =  this->buildType(this->getNamedTypeNode(typeNode));
        return this->buildWrappedType(typeDef, typeNode);
    }
    
    public function buildDirective(<DirectiveDefinitionNode> directiveNode)
    {
        var tmpArray73dfa8262ec54fda0970bfb5ffdfd1cb;
    
        let tmpArray73dfa8262ec54fda0970bfb5ffdfd1cb = ["name" : directiveNode->name->value, "description" : this->getDescription(directiveNode), "locations" : Utils::map(directiveNode->locations, new ASTDefinitionBuilderbuildDirectiveClosureOne()), "args" :  directiveNode->arguments ? FieldArgument::createMap(this->makeInputValues(directiveNode->arguments))  : null, "astNode" : directiveNode];
        return new Directive(tmpArray73dfa8262ec54fda0970bfb5ffdfd1cb);
    }
    
    public function buildField(<FieldDefinitionNode> field)
    {
        var tmpArrayafdac9933a6ec73c49b6d43532c9af9a;
    
        let tmpArrayafdac9933a6ec73c49b6d43532c9af9a = ["type" : this->internalBuildWrappedType(field->type), "description" : this->getDescription(field), "args" :  field->arguments ? this->makeInputValues(field->arguments)  : null, "deprecationReason" : this->getDeprecationReason(field), "astNode" : field];
        return tmpArrayafdac9933a6ec73c49b6d43532c9af9a;
    }
    
    protected function makeSchemaDef(def)
    {
        if !(def) {
            throw new Error("def must be defined.");
        }
        if NodeKind::OBJECT_TYPE_DEFINITION {
            return this->makeTypeDef(def);
        } elseif NodeKind::INPUT_OBJECT_TYPE_DEFINITION {
            return this->makeInputObjectDef(def);
        } elseif NodeKind::SCALAR_TYPE_DEFINITION {
            return this->makeScalarDef(def);
        } elseif NodeKind::UNION_TYPE_DEFINITION {
            return this->makeUnionDef(def);
        } elseif NodeKind::ENUM_TYPE_DEFINITION {
            return this->makeEnumDef(def);
        } elseif NodeKind::INTERFACE_TYPE_DEFINITION {
            return this->makeInterfaceDef(def);
        } else {
            throw new Error("Type kind of {def->kind} not supported.");
        }
    }
    
    protected function makeSchemaDefFromConfig(def, array config)
    {
        if !(def) {
            throw new Error("def must be defined.");
        }
        if NodeKind::OBJECT_TYPE_DEFINITION {
            return new ObjectType(config);
        } elseif NodeKind::INPUT_OBJECT_TYPE_DEFINITION {
            return new InputObjectType(config);
        } elseif NodeKind::SCALAR_TYPE_DEFINITION {
            return new CustomScalarType(config);
        } elseif NodeKind::UNION_TYPE_DEFINITION {
            return new UnionType(config);
        } elseif NodeKind::ENUM_TYPE_DEFINITION {
            return new EnumType(config);
        } elseif NodeKind::INTERFACE_TYPE_DEFINITION {
            return new InterfaceType(config);
        } else {
            throw new Error("Type kind of {def->kind} not supported.");
        }
    }
    
    protected function makeTypeDef(<ObjectTypeDefinitionNode> def)
    {
        var typeName, tmpArrayb7258486a02269cab6dd7c95e7d958c2;
    
        let typeName =  def->name->value;
        let tmpArrayb7258486a02269cab6dd7c95e7d958c2 = ["name" : typeName, "description" : this->getDescription(def), "fields" : new ASTDefinitionBuildermakeTypeDefClosureOne(def), "interfaces" : new ASTDefinitionBuildermakeTypeDefClosureOne(def), "astNode" : def];
        return new ObjectType(tmpArrayb7258486a02269cab6dd7c95e7d958c2);
    }
    
    protected function makeFieldDefMap(def)
    {
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  def->fields ? Utils::keyValMap(def->fields, new ASTDefinitionBuildermakeFieldDefMapClosureOne(), new ASTDefinitionBuildermakeFieldDefMapClosureOne())  : tmpArray40cd750bba9870f18aada2478b24840a;
    }
    
    protected function makeImplementedInterfaces(<ObjectTypeDefinitionNode> def)
    {
        if def->interfaces {
            // Note: While this could make early assertions to get the correctly
            // typed values, that would throw immediately while type system
            // validation with validateSchema() will produce more actionable results.
            return Utils::map(def->interfaces, new ASTDefinitionBuildermakeImplementedInterfacesClosureOne());
        }
        return null;
    }
    
    protected function makeInputValues(values)
    {
        var type, config;
    
        let type =  this->internalBuildWrappedType(value->type);
        let config =  ["name" : value->name->value, "type" : type, "description" : this->getDescription(value), "astNode" : value];
        let config["defaultValue"] = ast::valueFromAST(value->defaultValue, type);
        return Utils::keyValMap(values, new ASTDefinitionBuildermakeInputValuesClosureOne(), new ASTDefinitionBuildermakeInputValuesClosureOne());
    }
    
    protected function makeInterfaceDef(<InterfaceTypeDefinitionNode> def)
    {
        var typeName, tmpArray3541ecc38b7f8b62061458c997cc1e19;
    
        let typeName =  def->name->value;
        let tmpArray3541ecc38b7f8b62061458c997cc1e19 = ["name" : typeName, "description" : this->getDescription(def), "fields" : new ASTDefinitionBuildermakeInterfaceDefClosureOne(def), "astNode" : def];
        return new InterfaceType(tmpArray3541ecc38b7f8b62061458c997cc1e19);
    }
    
    protected function makeEnumDef(<EnumTypeDefinitionNode> def)
    {
        var tmpArrayeb7be3233d9693c04a7a86e0b11ff593, tmpArray89ac485de58a933b057668c39176a1d7;
    
        let tmpArrayeb7be3233d9693c04a7a86e0b11ff593 = ["name" : def->name->value, "description" : this->getDescription(def), "values" :  def->values ? Utils::keyValMap(def->values, new ASTDefinitionBuildermakeEnumDefClosureOne(), new ASTDefinitionBuildermakeEnumDefClosureOne())  : tmpArray40cd750bba9870f18aada2478b24840a, "astNode" : def];
        return new EnumType(tmpArrayc9a9b05feb4a1661519124f5e1b160da);
    }
    
    protected function makeUnionDef(<UnionTypeDefinitionNode> def)
    {
        var tmpArray064760dec93a687ed03a720b75d9af4d;
    
        let tmpArray064760dec93a687ed03a720b75d9af4d = ["name" : def->name->value, "description" : this->getDescription(def), "types" :  def->types ? Utils::map(def->types, new ASTDefinitionBuildermakeUnionDefClosureOne())  : tmpArray40cd750bba9870f18aada2478b24840a, "astNode" : def];
        return new UnionType(tmpArray4f64965b57461d6818b8aaa635d48df4);
    }
    
    protected function makeScalarDef(<ScalarTypeDefinitionNode> def)
    {
        var tmpArray32d8787117149456cbf82ef66af753f6;
    
        let tmpArray32d8787117149456cbf82ef66af753f6 = ["name" : def->name->value, "description" : this->getDescription(def), "astNode" : def, "serialize" : new ASTDefinitionBuildermakeScalarDefClosureOne()];
        return new CustomScalarType(tmpArray32d8787117149456cbf82ef66af753f6);
    }
    
    protected function makeInputObjectDef(<InputObjectTypeDefinitionNode> def)
    {
        var tmpArrayf7b1bd89189ef5130ace94248b06301a;
    
        let tmpArrayf7b1bd89189ef5130ace94248b06301a = ["name" : def->name->value, "description" : this->getDescription(def), "fields" : new ASTDefinitionBuildermakeInputObjectDefClosureOne(def), "astNode" : def];
        return new InputObjectType(tmpArrayf99b6626f6324223c2639a770ac32a9b);
    }
    
    /**
     * Given a collection of directives, returns the string value for the
     * deprecation reason.
     *
     * @param EnumValueDefinitionNode | FieldDefinitionNode $node
     * @return string
     */
    protected function getDeprecationReason(node) -> string
    {
        var deprecatedd;
    
        let deprecatedd =  Values::getDirectiveValues(Directive::deprecatedDirective(), node);
        return  isset deprecatedd["reason"] ? deprecatedd["reason"]  : null;
    }
    
    /**
     * Given an ast node, returns its string description.
     */
    protected function getDescription(node)
    {
        var rawValue;
    
        if node->description {
            return node->description->value;
        }
        if isset this->options["commentDescriptions"] {
            let rawValue =  this->getLeadingCommentBlock(node);
            if rawValue !== null {
                return BlockString::value("
" . rawValue);
            }
        }
        return null;
    }
    
    protected function getLeadingCommentBlock(node)
    {
        var loc, comments, token, value;
    
        let loc =  node->loc;
        if !(loc) || !(loc->startToken) {
            return null;
        }
        let comments =  [];
        let token =  loc->startToken->prev;
        while (token && token->kind === Token::COMMENT && token->next && token->prev && token->line + 1 === token->next->line && token->line !== token->prev->line) {
            let value =  token->value;
            let comments[] = value;
            let token =  token->prev;
        }
        return implode("
", array_reverse(comments));
    }

}