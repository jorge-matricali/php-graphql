namespace GraphQL\Utils;

class SchemaPrinterprintInputObjectClosureSeven
{
    private options;

    public function __construct(options)
    {
                let this->options = options;

    }

    public function __invoke(f, i)
    {
    return self::printDescription(this->options, f, "  ", !(i)) . "  " . self::printInputValue(f);
    }
}
    