namespace GraphQL\Type\Definition;

use GraphQL\Error\InvariantViolation;
use GraphQL\Utils\Utils;
/**
 * Class ListOfType
 * @package GraphQL\Type\Definition
 */
class ListOfType extends Type implements WrappingType, OutputType, InputType
{
    /**
     * @var ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType
     */
    public ofType;
    /**
     * @param callable|Type $type
     */
    public function __construct(type) -> void
    {
        let this->ofType =  Type::assertType(type);
    }
    
    /**
     * @return string
     */
    public function toString() -> string
    {
        var type, str;
    
        let type =  this->ofType;
        let str =  type instanceof Type ? type->toString()  : (string) type;
        return "[" . str . "]";
    }
    
    /**
     * @param bool $recurse
     * @return ObjectType|InterfaceType|UnionType|ScalarType|InputObjectType|EnumType
     */
    public function getWrappedType(bool recurse = false)
    {
        var type;
    
        let type =  this->ofType;
        return  recurse && type instanceof WrappingType ? type->getWrappedType(recurse)  : type;
    }

}