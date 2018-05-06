namespace GraphQL\Type;

class Introspection_directiveClosureEight
{

    public function __construct()
    {
        
    }

    public function __invoke(d)
    {
    return in_array(DirectiveLocation::FIELD, d->locations);
    }
}
    