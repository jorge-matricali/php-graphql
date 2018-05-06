namespace GraphQL\Utils;

class SchemaPrinterprintFilteredSchemaClosureTwo
{
    private directiveFilter;

    public function __construct(directiveFilter)
    {
                let this->directiveFilter = directiveFilter;

    }

    public function __invoke(directive)
    {
    return {this->directiveFilter}(directive);
    }
}
    