namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Language\AST\ListType;
use GraphQL\Language\AST\NamedType;
use GraphQL\Language\AST\NonNullType;
use GraphQL\Language\AST\TypeDefinitionNode;
use GraphQL\Type\Introspection;
use GraphQL\Utils\Utils;
/**
 * Registry of standard GraphQL types
 * and a base class for all other types.
 *
 * @package GraphQL\Type\Definition
 */
abstract class Type implements \JsonSerializable
{
    const STRING = "String";
    const INT = "Int";
    const BOOLEAN = "Boolean";
    const FLOAT = "Float";
    const ID = "ID";
    /**
     * @var array
     */
    protected static internalTypes;
    /**
     * @var array
     */
    protected static builtInTypes;
    /**
     * @api
     * @return IDType
     */
    public static function id() -> <IDType>
    {
        return self::getInternalType(self::ID);
    }
    
    /**
     * @api
     * @return StringType
     */
    public static function string() -> <StringType>
    {
        return self::getInternalType(self::STRING);
    }
    
    /**
     * @api
     * @return BooleanType
     */
    public static function boolean() -> <BooleanType>
    {
        return self::getInternalType(self::BOOLEAN);
    }
    
    /**
     * @api
     * @return IntType
     */
    public static function int() -> <IntType>
    {
        return self::getInternalType(self::INT);
    }
    
    /**
     * @api
     * @return FloatType
     */
    public static function float() -> <FloatType>
    {
        return self::getInternalType(self::FLOAT);
    }
    
    /**
     * @api
     * @param Type|ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType|NonNull $wrappedType
     * @return ListOfType
     */
    public static function listOf(wrappedType) -> <ListOfType>
    {
        return new ListOfType(wrappedType);
    }
    
    /**
     * @api
     * @param ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType $wrappedType
     * @return NonNull
     */
    public static function nonNull(wrappedType) -> <NonNull>
    {
        return new NonNull(wrappedType);
    }
    
    /**
     * @param $name
     * @return array|IDType|StringType|FloatType|IntType|BooleanType
     */
    protected static function getInternalType(name = null)
    {
        if self::internalTypes === null {
            let self::internalTypes =  [self::ID : new IDType(), self::STRING : new StringType(), self::FLOAT : new FloatType(), self::INT : new IntType(), self::BOOLEAN : new BooleanType()];
        }
        return  name ? self::internalTypes[name]  : self::internalTypes;
    }
    
    /**
     * Returns all builtin scalar types
     *
     * @return Type[]
     */
    public static function getInternalTypes() -> array
    {
        return self::getInternalType();
    }
    
    /**
     * Returns all builtin in types including base scalar and
     * introspection types
     *
     * @return Type[]
     */
    public static function getAllBuiltInTypes() -> array
    {
        if self::builtInTypes === null {
            let self::builtInTypes =  array_merge(Introspection::getTypes(), self::getInternalTypes());
        }
        return self::builtInTypes;
    }
    
    /**
     * Checks if the type is a builtin type
     *
     * @param Type $type
     * @return bool
     */
    public static function isBuiltInType(<Type> type) -> bool
    {
        return in_array(type->name, array_keys(self::getAllBuiltInTypes()));
    }
    
    /**
     * @api
     * @param Type $type
     * @return bool
     */
    public static function isInputType(<Type> type) -> bool
    {
        return type instanceof InputType && (!(type instanceof WrappingType) || self::getNamedType(type) instanceof InputType);
    }
    
    /**
     * @api
     * @param Type $type
     * @return bool
     */
    public static function isOutputType(<Type> type) -> bool
    {
        return type instanceof OutputType && (!(type instanceof WrappingType) || self::getNamedType(type) instanceof OutputType);
    }
    
    /**
     * @api
     * @param $type
     * @return bool
     */
    public static function isLeafType(type) -> bool
    {
        return type instanceof LeafType;
    }
    
    /**
     * @api
     * @param Type $type
     * @return bool
     */
    public static function isCompositeType(<Type> type) -> bool
    {
        return type instanceof CompositeType;
    }
    
    /**
     * @api
     * @param Type $type
     * @return bool
     */
    public static function isAbstractType(<Type> type) -> bool
    {
        return type instanceof AbstractType;
    }
    
    /**
     * @api
     * @param Type $type
     * @return bool
     */
    public static function isType(<Type> type) -> bool
    {
        return type instanceof ScalarType || type instanceof ObjectType || type instanceof InterfaceType || type instanceof UnionType || type instanceof EnumType || type instanceof InputObjectType || type instanceof ListOfType || type instanceof NonNull;
    }
    
    /**
     * @param mixed $type
     * @return mixed
     */
    public static function assertType(type)
    {
        Utils::invariant(self::isType(type), "Expected " . Utils::printSafe(type) . " to be a GraphQL type.");
        return type;
    }
    
    /**
     * @api
     * @param Type $type
     * @return ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType
     */
    public static function getNullableType(<Type> type)
    {
        return  type instanceof NonNull ? type->getWrappedType()  : type;
    }
    
    /**
     * @api
     * @param Type $type
     * @return ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType
     */
    public static function getNamedType(<Type> type)
    {
        if type === null {
            return null;
        }
        while (type instanceof WrappingType) {
            let type =  type->getWrappedType();
        }
        return type;
    }
    
    /**
     * @var string
     */
    public name;
    /**
     * @var string|null
     */
    public description;
    /**
     * @var TypeDefinitionNode|null
     */
    public astNode;
    /**
     * @var array
     */
    public config;
    /**
     * @return null|string
     */
    protected function tryInferName()
    {
        var tmp, name;
    
        if this->name {
            return this->name;
        }
        // If class is extended - infer name from className
        // QueryType -> Type
        // SomeOtherType -> SomeOther
        let tmp =  new \ReflectionClass(this);
        let name =  tmp->getShortName();
        if tmp->getNamespaceName() !== __NAMESPACE__ {
            return preg_replace("~Type$~", "", name);
        }
        return null;
    }
    
    /**
     * @throws InvariantViolation
     */
    public function assertValid() -> void
    {
        Utils::assertValidName(this->name);
    }
    
    /**
     * @return string
     */
    public function toString() -> string
    {
        return this->name;
    }
    
    /**
     * @return string
     */
    public function jsonSerialize() -> string
    {
        return this->toString();
    }
    
    /**
     * @return string
     */
    public function __toString() -> string
    {
        var e;
    
        try {
            return this->toString();
        } catch \Exception, e {
            echo e;
        } catch \Throwable, e {
            echo e;
        }
    }

}