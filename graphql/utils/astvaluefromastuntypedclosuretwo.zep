namespace GraphQL\Utils;

class astvalueFromASTUntypedClosureTwo
{

    public function __construct()
    {
        
    }

    public function __invoke(field)
    {
    return field->name->value;
    }
}
    