namespace GraphQL\Utils;

class BuildSchemabuildSchemaClosureFive
{
    private defintionBuilder;

    public function __construct(defintionBuilder)
    {
                let this->defintionBuilder = defintionBuilder;

    }

    public function __invoke(name)
    {
    return this->defintionBuilder->buildType(name);
    }
}
    