namespace GraphQL\Utils;

class TypeInfoextractTypesClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(FieldArgument arg)
    {
    return arg->getType();
    }
}
    