namespace GraphQL\Utils;

class SchemaPrinterprintEnumValuesClosureSix
{
    private options;

    public function __construct(options)
    {
                let this->options = options;

    }

    public function __invoke(value, i)
    {
    return self::printDescription(this->options, value, "  ", !(i)) . "  " . value->name . self::printDeprecated(value);
    }
}
    