namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Utils\Utils;
/**
 * Class NonNull
 * @package GraphQL\Type\Definition
 */
class NonNull extends Type implements WrappingType, OutputType, InputType
{
    /**
     * @param mixed $type
     * @return self
     */
    public static function assertNullType(type)
    {
        Utils::invariant(type instanceof self, "Expected " . Utils::printSafe(type) . " to be a GraphQL Non-Null type.");
        return type;
    }
    
    /**
     * @param mixed $type
     * @return ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType
     */
    public static function assertNullableType(type)
    {
        Utils::invariant(Type::isType(type) && !(type instanceof self), "Expected " . Utils::printSafe(type) . " to be a GraphQL nullable type.");
        return type;
    }
    
    /**
     * @var ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType
     */
    protected ofType;
    /**
     * @param callable|Type $type
     * @throws \Exception
     */
    public function __construct(type) -> void
    {
        let this->ofType =  self::assertNullableType(type);
    }
    
    /**
     * @param bool $recurse
     * @return ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType|ListOfType
     * @throws InvariantViolation
     */
    public function getWrappedType(bool recurse = false)
    {
        var type;
    
        let type =  this->ofType;
        return  recurse && type instanceof WrappingType ? type->getWrappedType(recurse)  : type;
    }
    
    /**
     * @return string
     */
    public function toString() -> string
    {
        return this->getWrappedType()->toString() . "!";
    }

}