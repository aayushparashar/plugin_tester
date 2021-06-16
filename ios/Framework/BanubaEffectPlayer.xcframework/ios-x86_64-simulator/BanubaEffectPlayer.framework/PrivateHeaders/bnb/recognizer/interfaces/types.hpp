#pragma once

#include <bnb/recognizer/interfaces/all.hpp>
#include <memory>

namespace bnb::interfaces
{
    using feature_sptr = std::shared_ptr<feature>;
    using feature_wptr = std::weak_ptr<feature>;
    using feature_uptr = std::unique_ptr<feature>;
    using feature_ptr = bnb::interfaces::feature*;

    using recognizer_sptr = std::shared_ptr<recognizer>;
    using recognizer_wptr = std::weak_ptr<recognizer>;
    using recognizer_uptr = std::unique_ptr<recognizer>;
    using recognizer_ptr = bnb::interfaces::recognizer*;

}
