package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.dto.user.UserUpdateRequestDTO;
import br.com.hematsu.lance_certo.model.User;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface UserMapper {

    User userRegistrationRequestDTOToUser(UserRegistrationRequestDTO dto);

    User userUpdateRequestDTOToUser(UserUpdateRequestDTO dto);

    User userResponseDTOToUser(UserResponseDTO dto);

    UserResponseDTO userToUserResponseDTO(User user);

}
