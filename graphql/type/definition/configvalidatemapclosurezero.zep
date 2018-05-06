namespace GraphQL\Type\Definition;

class ConfigvalidateMapClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(def)
    {
    return (self::getFlags(def) & self::REQUIRED) > 0;
    }
}
    