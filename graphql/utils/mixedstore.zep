namespace GraphQL\Utils;

/**
 * Similar to PHP array, but allows any type of data to act as key (including arrays, objects, scalars)
 *
 * Note: unfortunately when storing array as key - access and modification is O(N)
 * (yet this should be really rare case and should be avoided when possible)
 *
 * Class MixedStore
 * @package GraphQL\Utils
 */
class MixedStore implements \ArrayAccess
{
    /**
     * @var array
     */
    protected standardStore;
    /**
     * @var array
     */
    protected floatStore;
    /**
     * @var \SplObjectStorage
     */
    protected objectStore;
    /**
     * @var array
     */
    protected arrayKeys;
    /**
     * @var array
     */
    protected arrayValues;
    /**
     * @var array
     */
    protected lastArrayKey;
    /**
     * @var mixed
     */
    protected lastArrayValue;
    /**
     * @var mixed
     */
    protected nullValue;
    /**
     * @var bool
     */
    protected nullValueIsSet;
    /**
     * @var mixed
     */
    protected trueValue;
    /**
     * @var bool
     */
    protected trueValueIsSet;
    /**
     * @var mixed
     */
    protected falseValue;
    /**
     * @var bool
     */
    protected falseValueIsSet;
    /**
     * MixedStore constructor.
     */
    public function __construct() -> void
    {
        let this->standardStore =  [];
        let this->floatStore =  [];
        let this->objectStore =  new \SplObjectStorage();
        let this->arrayKeys =  [];
        let this->arrayValues =  [];
        let this->nullValueIsSet =  false;
        let this->trueValueIsSet =  false;
        let this->falseValueIsSet =  false;
    }
    
    /**
     * Whether a offset exists
     * @link http://php.net/manual/en/arrayaccess.offsetexists.php
     * @param mixed $offset <p>
     * An offset to check for.
     * </p>
     * @return boolean true on success or false on failure.
     * </p>
     * <p>
     * The return value will be casted to boolean if non-boolean was returned.
     * @since 5.0.0
     */
    public function offsetExists(offset) -> boolean
    {
        var index, entry;
    
        if offset === false {
            return this->falseValueIsSet;
        }
        if offset === true {
            return this->trueValueIsSet;
        }
        if is_int(offset) || is_string(offset) {
            return array_key_exists(offset, this->standardStore);
        }
        if is_float(offset) {
            return array_key_exists((string) offset, this->floatStore);
        }
        if is_object(offset) {
            return this->objectStore->offsetExists(offset);
        }
        if is_array(offset) {
            for index, entry in this->arrayKeys {
                if entry === offset {
                    let this->lastArrayKey = offset;
                    let this->lastArrayValue = this->arrayValues[index];
                    return true;
                }
            }
        }
        if offset === null {
            return this->nullValueIsSet;
        }
        return false;
    }
    
    /**
     * Offset to retrieve
     * @link http://php.net/manual/en/arrayaccess.offsetget.php
     * @param mixed $offset <p>
     * The offset to retrieve.
     * </p>
     * @return mixed Can return all value types.
     * @since 5.0.0
     */
    public function offsetGet(offset)
    {
        var index, entry;
    
        if offset === true {
            return this->trueValue;
        }
        if offset === false {
            return this->falseValue;
        }
        if is_int(offset) || is_string(offset) {
            return this->standardStore[offset];
        }
        if is_float(offset) {
            return this->floatStore[(string) offset];
        }
        if is_object(offset) {
            return this->objectStore->offsetGet(offset);
        }
        if is_array(offset) {
            // offsetGet is often called directly after offsetExists, so optimize to avoid second loop:
            if this->lastArrayKey === offset {
                return this->lastArrayValue;
            }
            for index, entry in this->arrayKeys {
                if entry === offset {
                    return this->arrayValues[index];
                }
            }
        }
        if offset === null {
            return this->nullValue;
        }
        return null;
    }
    
    /**
     * Offset to set
     * @link http://php.net/manual/en/arrayaccess.offsetset.php
     * @param mixed $offset <p>
     * The offset to assign the value to.
     * </p>
     * @param mixed $value <p>
     * The value to set.
     * </p>
     * @return void
     * @since 5.0.0
     */
    public function offsetSet(offset, value)
    {
        if offset === false {
            let this->falseValue = value;
            let this->falseValueIsSet =  true;
        } else {
            if offset === true {
                let this->trueValue = value;
                let this->trueValueIsSet =  true;
            } else {
                if is_int(offset) || is_string(offset) {
                    let this->standardStore[offset] = value;
                } else {
                    if is_float(offset) {
                        let this->floatStore[(string) offset] = value;
                    } else {
                        if is_object(offset) {
                            let this->objectStore[offset] = value;
                        } else {
                            if is_array(offset) {
                                let this->arrayKeys[] = offset;
                                let this->arrayValues[] = value;
                            } else {
                                if offset === null {
                                    let this->nullValue = value;
                                    let this->nullValueIsSet =  true;
                                } else {
                                    throw new \InvalidArgumentException("Unexpected offset type: " . Utils::printSafe(offset));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Offset to unset
     * @link http://php.net/manual/en/arrayaccess.offsetunset.php
     * @param mixed $offset <p>
     * The offset to unset.
     * </p>
     * @return void
     * @since 5.0.0
     */
    public function offsetUnset(offset)
    {
        var index;
    
        if offset === true {
            let this->trueValue =  null;
            let this->trueValueIsSet =  false;
        } else {
            if offset === false {
                let this->falseValue =  null;
                let this->falseValueIsSet =  false;
            } else {
                if is_int(offset) || is_string(offset) {
                    unset this->standardStore[offset];
                
                } else {
                    if is_float(offset) {
                        unset this->floatStore[(string) offset];
                    
                    } else {
                        if is_object(offset) {
                            this->objectStore->offsetUnset(offset);
                        } else {
                            if is_array(offset) {
                                let index =  array_search(offset, this->arrayKeys, true);
                                if index !== false {
                                    array_splice(this->arrayKeys, index, 1);
                                    array_splice(this->arrayValues, index, 1);
                                }
                            } else {
                                if offset === null {
                                    let this->nullValue =  null;
                                    let this->nullValueIsSet =  false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}