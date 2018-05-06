namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureOne
{
    private defintionBuilder;

    public function __construct(defintionBuilder)
    {
                let this->defintionBuilder = defintionBuilder;

    }

    public function __invoke(def)
    {
    return this->defintionBuilder->buildDirective(def);
    }
}
    