namespace GraphQL\Type\Definition;

use GraphQL\Error\Error;
use GraphQL\Language\AST\IntValueNode;
use GraphQL\Utils\Utils;
/**
 * Class IntType
 * @package GraphQL\Type\Definition
 */
class IntType extends ScalarType
{
    // As per the GraphQL Spec, Integers are only treated as valid when a valid
    // 32-bit signed integer, providing the broadest support across platforms.
    //
    // n.b. JavaScript's integers are safe between -(2^53 - 1) and 2^53 - 1 because
    // they are internally represented as IEEE 754 doubles.
    const MAX_INT = 2147483647;
    const MIN_INT = -2147483648;
    /**
     * @var string
     */
    public name = Type::INT;
    /**
     * @var string
     */
    public description = "The `Int` scalar type represents non-fractional signed whole numeric
values. Int can represent values between -(2^31) and 2^31 - 1. ";
    /**
     * @param mixed $value
     * @return int|null
     * @throws Error
     */
    public function serialize(value)
    {
        return this->coerceInt(value);
    }
    
    /**
     * @param mixed $value
     * @return int|null
     * @throws Error
     */
    public function parseValue(value)
    {
        return this->coerceInt(value);
    }
    
    /**
     * @param $valueNode
     * @param array|null $variables
     * @return int|null
     */
    public function parseLiteral(valueNode, array variables = null)
    {
        var val;
    
        if valueNode instanceof IntValueNode {
            let val =  (int) valueNode->value;
            if valueNode->value === (string) val && self::MIN_INT <= val && val <= self::MAX_INT {
                return val;
            }
        }
        return Utils::undefined();
    }
    
    protected function coerceInt(value)
    {
        var num, intt;
    
        if value === "" {
            throw new Error("Int cannot represent non 32-bit signed integer value: (empty string)");
        }
        let num =  floatval(value);
        if !(is_numeric(value)) && !(is_bool(value)) || num > self::MAX_INT || num < self::MIN_INT {
            throw new Error("Int cannot represent non 32-bit signed integer value: " . Utils::printSafe(value));
        }
        let intt =  intval(num);
        if intt != num {
            throw new Error("Int cannot represent non-integer value: " . Utils::printSafe(value));
        }
        return intt;
    }

}