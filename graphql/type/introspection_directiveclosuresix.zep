namespace GraphQL\Type;

class Introspection_directiveClosureSix
{

    public function __construct()
    {
        
    }

    public function __invoke(d)
    {
    return in_array(DirectiveLocation::QUERY, d->locations) || in_array(DirectiveLocation::MUTATION, d->locations) || in_array(DirectiveLocation::SUBSCRIPTION, d->locations);
    }
}
    