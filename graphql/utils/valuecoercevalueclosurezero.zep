namespace GraphQL\Utils;

class ValuecoerceValueClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(enumValue)
    {
    return enumValue->name;
    }
}
    