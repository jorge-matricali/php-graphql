namespace GraphQL\Type;

class Introspection_directiveClosureSeven
{

    public function __construct()
    {
        
    }

    public function __invoke(d)
    {
    return in_array(DirectiveLocation::FRAGMENT_SPREAD, d->locations) || in_array(DirectiveLocation::INLINE_FRAGMENT, d->locations) || in_array(DirectiveLocation::FRAGMENT_DEFINITION, d->locations);
    }
}
    