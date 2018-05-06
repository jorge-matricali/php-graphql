namespace GraphQL\Utils;

/**
 * A way to keep track of pairs of things when the ordering of the pair does
 * not matter. We do this by maintaining a sort of double adjacency sets.
 */
class PairSet
{
    /**
     * @var array
     */
    protected data;
    /**
     * PairSet constructor.
     */
    public function __construct() -> void
    {
        let this->data =  [];
    }
    
    /**
     * @param string $a
     * @param string $b
     * @param bool $areMutuallyExclusive
     * @return bool
     */
    public function has(string a, string b, bool areMutuallyExclusive) -> bool
    {
        var first, result;
    
        let first =  isset this->data[a] ? this->data[a]  : null;
        let result =  first && isset first[b] ? first[b]  : null;
        if result === null {
            return false;
        }
        // areMutuallyExclusive being false is a superset of being true,
        // hence if we want to know if this PairSet "has" these two with no
        // exclusivity, we have to ensure it was added as such.
        if areMutuallyExclusive === false {
            return result === false;
        }
        return true;
    }
    
    /**
     * @param string $a
     * @param string $b
     * @param bool $areMutuallyExclusive
     */
    public function add(string a, string b, bool areMutuallyExclusive) -> void
    {
        this->pairSetAdd(a, b, areMutuallyExclusive);
        this->pairSetAdd(b, a, areMutuallyExclusive);
    }
    
    /**
     * @param string $a
     * @param string $b
     * @param bool $areMutuallyExclusive
     */
    protected function pairSetAdd(string a, string b, bool areMutuallyExclusive) -> void
    {
        let this->data[a] =  isset this->data[a] ? this->data[a]  : [];
        let this->data[a][b] = areMutuallyExclusive;
    }

}