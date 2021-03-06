/// \file
/// \addtogroup Types
/// @{
///
// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from types.djinni

#pragma once

#include "bnb/types/interfaces/pixel_rect.hpp"
#include <utility>
#include <vector>

namespace bnb { namespace interfaces {

struct acne_regions final {
    std::vector<pixel_rect> regions;
    /** (common -> rect) transformation */
    std::vector<float> basis_transform;

    acne_regions(std::vector<pixel_rect> regions_,
                 std::vector<float> basis_transform_)
    : regions(std::move(regions_))
    , basis_transform(std::move(basis_transform_))
    {}
};

} }  // namespace bnb::interfaces
/// @}

