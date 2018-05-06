namespace GraphQL\Utils;

class SchemaPrinterdoPrintClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(type)
    {
    return !(Directive::isSpecifiedDirective(type));
    }
}
    